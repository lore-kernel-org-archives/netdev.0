From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Fri, 30 Apr 2010 20:26:54 -0400
Message-ID: <1272673614.14499.10.camel@bigi>
References: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
	<4BDB3F07.2030900@free.fr>  <87bpd0zl9l.fsf@caffeine.danplanet.com>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Vlad Yasevich <vladislav.yasevich-VXdhtT5mjnY@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bpd0zl9l.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-04-30 at 14:24 -0700, Dan Smith wrote:

> 
> I'm sure it would be doable.  However, checkpointing the routes that
> way would:
> 
> (a) Be inconsistent with how we checkpoint all the other resources,
>     including the other network resources we handle from the kernel
>     with rtnl

My 2c:
The problem as i see it (with all net structures not just routes - i was
equally pessimistic when i saw those other net structure
checkpoint/restore changes) is you are faced with a herculean
high-maintainance effort...
You have a separate piece of code which populates structures that _you_
maintain for attributes that are defined elsewhere by other people.
Nobody adding a new attribute that is very important to route
restoration for example is likely to change your code. Unless you tie
the two together (so changing one forces the coder to change the other).
And once people deploy kernels it is hard to change. Historically (for
pragmatic reasons) such rich interfaces sit in user space - much easier
to update user space.
 
cheers,
jamal
