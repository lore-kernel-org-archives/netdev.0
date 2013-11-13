From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] linux: Signal datapath that unaligned Netlink
 message can be received
Date: Wed, 13 Nov 2013 14:11:42 +0800
Message-ID: <CAEP_g=_KWgmfVkNLPGYr=WjNR=UKSt3PhkqU8PE6Ug3ju2R3ig@mail.gmail.com>
References: <51e10053434e3afdf9940d9be7d9f0ff4788d1f7.1384184155.git.tgraf@redhat.com>
	<20131111155014.GC32602@nicira.com> <5280FD6D.9000609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, fleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	dborkmann-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
To: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <5280FD6D.9000609-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 11, 2013 at 11:53 PM, Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 11/11/2013 04:50 PM, Ben Pfaff wrote:
>>
>> On Mon, Nov 11, 2013 at 04:36:24PM +0100, Thomas Graf wrote:
>>>
>>> Following commit (''netlink: Do not enforce alignment of last Netlink
>>> attribute''), signal the ability to receive unaligned Netlink messages
>>> to the datapath to enable utilization of zerocopy optimizations.
>>>
>>> Signed-off-by: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>
>>
>> Seems OK from a userspace point of view.  I am a little concerned that
>> downgrading userspace without deleting and re-creating the datapath
>> (e.g. via "force-reload-kmod") will result in a totally broken setup
>> since userspace will then drop every packet from the kernel.
>
>
> Is that something that occurs occasionally in installations? Utilizing
> the version field in the genl header could be used to track this and
> clear user_features.

It's probably a good idea. I could see us having more of these
features flags in the future (although obviously we should try to
avoid them if possible) and, as Ben said, it would potentially lead to
a bad state otherwise.

I'm not sure exactly what you have in mind though, can you elaborate a little?

(By the way, it might be a good idea to keep the same CC list on all
of the patches. Otherwise, some people might miss parts of the
discussion.)
