From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.50
Date: Wed, 04 Dec 2002 12:42:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DEE3E6E.30407@pobox.com>
References: <Pine.GSO.4.30.0212040806590.2731-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Rompf <srompf@isg.de>, "David S. Miller" <davem@redhat.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0212040806590.2731-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Stefans curtrent patch makes the info available via netlink.

He has two patches:  link change notification, and RFC2863 operstatus. 
I agree with the first one and support its inclusion; the second one I 
question its need.

(just for context, I am referring to message <3DED2EA9.D812C881@isg.de> 
dated Dec 3)


> What dont you like about it Jeff? Take a quick look at RFC2863
> and scan for IfAdminStatus and IfOperStatus. The modelling RFC2863
> has is pretty good and thats what Stefan has followed (after we weeded
> a few crappy pieces off the RFC; we discussed on netdev).

I had looked at ifAdminStatus and ifOperStatus before I posted :)

My argument is, _after_ Stefan's link state patch is applied, why do we 
need the additional patch?  [this question is meant to be delivered in 
an honest, not snide way...]

For ifAdminStatus, you have "up", "down", and "testing" states.  Since 
we have no concept of a testing state, if we eliminate that we have "up" 
and "down", two states we can obviously handle.

For ifOperStatus, we have "up", "down" and "testing", which are 
applicable (or not) to Linux as with ifAdminStatus.  Further we have 
states "dormant", "unknown", "notPresent", "lowerLayerDown".  I'll 
discuss each of these in detail.

"dormant" - not used in Stefan's patch, which I agree with.
"unknown" - only used in Stefan's patch before interface is first up'd, 
which is IMO inaccurate.  Accurate use of "up" and "down", to me, 
implies -no- use of "unknown" state.  Because as soon as we are 
initialized, all ethernet details are known, thus "down" is more 
applicable.  The Linux net stack's atomicity is such that leaking an 
"unknown" state would be a bug, too.
"notPresent" - analagous to Linux's netif_device_xxx, and Stefan's patch 
acknowledges this.  However, the use of netif_device_xxx in drivers is 
really only used when the hardware is suspended.  If hardware goes away, 
the interface goes away too, almost immediately.
"lowerLayerDown" - not used in Stefan's patch, which I agree with.

So, Stefan's 2nd patch really only adds "unknown" and "notPresent" 
states to current behavior -- and the applicability of those states to 
Linux is IMO questionable.

Questions/comments requested.

Regards,

	Jeff
