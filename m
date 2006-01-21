From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: My vote against eepro* removal
Date: Fri, 20 Jan 2006 19:40:50 -0500
Message-ID: <1137804050.3241.32.camel@mindpipe>
References: <AAD6DA242BC63C488511C611BD51F367323324@MAILIT.keba.co.at>
	 <20060120095548.GA16000@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kus Kusche Klaus <kus@keba.com>,
	John Ronciak <john.ronciak@gmail.com>,
	Adrian Bunk <bunk@stusta.de>, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932333AbWAUAky@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060120095548.GA16000@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-20 at 12:55 +0300, Evgeniy Polyakov wrote:
> > Analysis of e100:
> > * If I comment out the whole body of e100_watchdog except for the
> >   timer re-registration, the delays are gone (so it is really the
> >   body of e100_watchdog). However, this makes eth0 non-functional.
> > * Commenting out parts of it, I found out that most of the time
> >   goes into its first half: The code from mii_ethtool_gset to
> >   mii_check_link (including) makes the big difference, as far as
> >   I can tell especially mii_ethtool_gset.
> 
> Each MDIO read can take upto 2 msecs (!) and at least 20 usecs in
> e100,
> and this runs in timer handler.
> Concider attaching (only compile tested) patch which moves e100
> watchdog
> into workqueue. 

Seems like the important question is, why does e100 need a watchdog if
eepro100 works fine without one?  Isn't the point of a watchdog in this
context to work around other bugs in the driver (or the hardware)?

Lee
