From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.50
Date: Mon, 9 Dec 2002 22:55:32 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021210035532.GA22559@gtf.org>
References: <3DEE3E6E.30407@pobox.com> <Pine.GSO.4.30.0212090810520.19181-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Rompf <srompf@isg.de>, "David S. Miller" <davem@redhat.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0212090810520.19181-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Dec 09, 2002 at 08:27:39AM -0500, jamal wrote:
> On Wed, 4 Dec 2002, Jeff Garzik wrote:
> > For ifAdminStatus, you have "up", "down", and "testing" states.  Since
> > we have no concept of a testing state, if we eliminate that we have "up"
> > and "down", two states we can obviously handle.
> >
> > For ifOperStatus, we have "up", "down" and "testing", which are
> > applicable (or not) to Linux as with ifAdminStatus.  Further we have
> > states "dormant", "unknown", "notPresent", "lowerLayerDown".  I'll
> > discuss each of these in detail.
> >
> > "dormant" - not used in Stefan's patch, which I agree with.
> > "unknown" - only used in Stefan's patch before interface is first up'd,
> > which is IMO inaccurate.  Accurate use of "up" and "down", to me,
> > implies -no- use of "unknown" state.  Because as soon as we are
> > initialized, all ethernet details are known, thus "down" is more
> > applicable.  The Linux net stack's atomicity is such that leaking an
> > "unknown" state would be a bug, too.
> > "notPresent" - analagous to Linux's netif_device_xxx, and Stefan's patch
> > acknowledges this.  However, the use of netif_device_xxx in drivers is
> > really only used when the hardware is suspended.  If hardware goes away,
> > the interface goes away too, almost immediately.
> > "lowerLayerDown" - not used in Stefan's patch, which I agree with.
> >
> > So, Stefan's 2nd patch really only adds "unknown" and "notPresent"
> > states to current behavior -- and the applicability of those states to
> > Linux is IMO questionable.
> >
> 
> If all he is adding are some enumerated types, theres no harm. I cant
> remember the details of the discussions - but we had long winding
> discussions on the different states.

I would summarize his patch as adding variable to represent literally
ifOperStatus, along with a lock and apparatus to set this variable.

The value may be deduced, without having to literally track it.


> Note you need both admin and operational status and physically thet may
> mean different things (think PPP and ethernet for example). You also need
> to properly reflect the status for all sorts of netdevices. As long as
> those requirements are met, then all is good. The RFC is not the final
> word but it draws from experiences people had for years doing this kind
> of stuff - so it is a good idea to draw from their experiences (but ok to
> ignore it if it sounds unrealistic).

I think we do agree on interpretation as you describe it here.
And the linkwatch patch is now in Linux 2.5.51.  I just think the
further patch to "track literally" ifOperStatus is not needed.  However,
that is presented as an opinion and RFC, not a statement of fact :)

	Jeff
