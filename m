From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v7 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Wed, 5 Oct 2016 10:51:06 +0200
Message-ID: <20161005085106.GI5575@lunn.ch>
References: <1475589845-29182-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20161004143450.GP11677@lunn.ch>
 <20161005083642.GA13404@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161005083642.GA13404-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 05, 2016 at 02:06:43PM +0530, Raju Lakkaraju wrote:
> Hi Andrew,
> 
> Thank you for review comment.
> 
> On Tue, Oct 04, 2016 at 04:34:50PM +0200, Andrew Lunn wrote:
> > EXTERNAL EMAIL
> > 
> > 
> > > v7:
> > > - As per review comment, Removed '-'s (minus) sign in Edge rate table.
> > 
> > Still no exact match on the table.
> > 
> > So if i specify a voltage of 3301, 53% slowdown it looks i will
> > actually get 0% slowdown and no error message. That is not very
> > helpful.
> > 
> 
> According to my understanding, User should choose the right VDDMAC voltage
> (i.e. 3.3V or 2.5V or 1.8V or 1.5V).

And user do make typos, don't read the documentation, etc and get it
wrong. The way you have implemented this, does not help the user
figure out what they have wrong. It silently does something totally
unexpected.
 
> Do you want me to add an error trace which will inform the user that the 
> configured values can not be supported - or if the driver should pick 
> the "closest" value it can support (or both).

You should validate what the user has requested via DT is valid, and
it not, return -EINVAL during probe. That should cause the PHY driver
to fail to load, making it clear something is bad in the device tree.
A dev_err() call saying which parameter is invalid would also be nice.

  Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
