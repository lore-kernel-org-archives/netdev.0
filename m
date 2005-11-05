From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [IPV4] Fix secondary IP addresses after promotion
Date: Sat, 5 Nov 2005 20:06:36 +0100
Message-ID: <20051105190636.GU23537@postel.suug.ch>
References: <20051104184633.GA16256@skull.piratehaven.org> <436BFE08.6030906@trash.net> <20051105010740.GR23537@postel.suug.ch> <20051105183910.GA17215@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Brian Pomerantz <bapper@piratehaven.org>,
	netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932290AbVKETGT@vger.kernel.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20051105183910.GA17215@ms2.inr.ac.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Local routes for 10.0.0.3 and 10.0.0.4 have disappeared _without_
> > any notification.
> 
> Flushes do not generate notifications. The reason is technical: they
> are usually massive, do overflow buffer, get lost and listeners have
> to do painful resynchronization. The justification: they are useless
> because these events are derived.

I perfectly agree, still I'm not happy with deleting the local routes
for the temporarly orphaned secondaries without notifications and
just re-add them again later.

I think we should either prevent the deletion of the local routes by
rewriting their preferred source address during promotion or explicitely
announce the temprary orphaned secondaries as down and up again in order
to have the local routes deleted/re-added in a clean way.
