From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] ipv4: in new netns initialize sysctls in net.ipv4.conf.*
	with defaults
Date: Wed, 24 Feb 2016 16:05:10 -0600
Message-ID: <87y4a9ix2h.fsf@x220.int.ebiederm.org>
References: <20160221071102.9686.63148.stgit@buzz>
	<20160223.182121.2101846699151527296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, vvs-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160223.182121.2101846699151527296.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Tue, 23 Feb 2016 18:21:21 -0500 (EST)")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
> Date: Sun, 21 Feb 2016 10:11:02 +0300
>
>> Currently initial net.ipv4.conf.all.* and net.ipv4.conf.default.* are
>> copied from init network namespace because static structures are used
>> for init_net. This makes no sense because new netns might be created
>> from any netns. This patch makes private copy also for init netns if
>> network namespaces are enabled. Other sysctls in net.ipv4 and net.ipv6
>> already initialized with default values at namespace creation.
>> 
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
>> Fixes: 752d14dc6aa9 ("[IPV4]: Move the devinet pointers on the struct net")
>
> The horse has long left the stable on this.  We cannot change this now
> without breaking things.
>
> Imagine someone who intentionally sets up init_net with a certain set
> of settings and expects them to propagate into every created namespace.
>
> We'll break things for them and given the behavior existed for so long
> what the administrator is doing is very reasonable.
>
> I'm not applying this sorry, we are stuck with the current behavior
> whether we like it or not.

Dave I won't argue that the patch reaches the proper trade-off with
existing software.  Certainly the lack of testing and other exploration
in this regard with the submitted patch is concerning.

In the general case the current behavior is random and not something
applications can count on, and we would do well to fix it so it is less
random.  In particular consider the case of an application in a
non-initial network namespace creating a new network namespace.  It is
not even possible to predict what values they will get for sysctls
today.

>From a backwards compatibility standpoint we are probably better off
with copying from the current network namespace rather than the initial
network namespace.  As that more closely resembles the common case
today.

Having a statement of something that is a problem today with the
existing setup would probably be useful so it is clear this is not a
change for the sake of change.

Eric
