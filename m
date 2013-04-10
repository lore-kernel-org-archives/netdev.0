From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2/2 v4] sierra_net: keep status interrupt URB active
Date: Wed, 10 Apr 2013 09:57:50 -0500
Message-ID: <1365605870.28888.70.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1365548547.23372.2.camel@dcbw.foobar.com>
	 <1365548751.23372.6.camel@dcbw.foobar.com>
	 <4949544.d8fOCnDANj@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936826Ab3DJO4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Apr 2013 10:56:45 -0400
In-Reply-To: <4949544.d8fOCnDANj@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-10 at 09:15 +0200, Oliver Neukum wrote:
> On Tuesday 09 April 2013 18:05:51 Dan Williams wrote:
> > The driver and firmware sync up through SYNC messages, and the
> > firmware's affirmative reply to these SYNC messages appears to be the
> > "Reset" indication received via the status interrupt endpoint.  Thus the
> > driver needs the status interrupt endpoint always active so that the
> > Reset indication can be received even if the netdev is closed, which is
> > the case right after device insertion.
> 
> WHat about suspend/resume?

usbnet should take care of that transparently from the sub-drivers
through it's own suspend/resume logic to kill/resubmit the URB if
required.  Though is there something I'm missing here?

Dan
