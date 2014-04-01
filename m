From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: supply a dummy err_handler of
 gre_cisco_protocol to prevent kernel crash
Date: Mon, 31 Mar 2014 17:49:53 -0700
Message-ID: <CAEP_g=_84HXCZLOzQ0JdLBF5WVhqwTJeEAY-xjqDD8YCv8yrRg@mail.gmail.com>
References: <1395957398-24546-1-git-send-email-asuka.com@163.com>
 <CAEP_g=_qJ1uHKZmZdkUrT+NUkzbRgaHfShZoMbnnCb+LwjOneQ@mail.gmail.com>
 <4fd27e6c.c96a.14512e82018.Coremail.asuka.com@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: wei zhang <asuka.com-9Onoh4P/yGk@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <4fd27e6c.c96a.14512e82018.Coremail.asuka.com-9Onoh4P/yGk@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Sun, Mar 30, 2014 at 5:12 AM, wei zhang <asuka.com-9Onoh4P/yGk@public.gmane.org> wrote:
> At 2014-03-29 06:02:25,"Jesse Gross" <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>
>>I'm not sure that rejecting all ICMP packets is the correct thing do
>>here since it means that we could pass them onto a later caller even
>>though they are intended for us. We should probably use the same logic
>>as for receiving packets and just discard them here.
>
> Thank you very much for your advice, did you mean this logic?

Yes, that's what I was thinking.

[...]

> Maybe I misunderstand something? I think if we discard all packet pass to us
> when we use gre vport, new gre_cisco_protocol which has lower priority could
> not see the packet intended to it.

That's true but in this case it would also not see any data packets,
so I don't think that situation would work well anyways.

> I checked the implementation of the ipgre_err(), which has be called before
> the err_handler of gre vport. It use the the (local address, remote address, key)
> to distinguish the packet which is realy intended to it, although it could not
> always get the key from the icmp packet. Should we do as the same as it?
> I'm not sure this is feasible, any advice is appreciate.

OVS does flow based matching rather than using a static set of
configuration parameters, so everything "matches" in some way
(although the result might be to drop). This generally means that OVS
is the receiver of last resort and nothing currently has a lower
priority. That actually means the difference between the patches is
somewhat academic but it seems more robust for the logic to be
consistent.
