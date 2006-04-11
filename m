From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] deinline a few large functions in vlan code v2
Date: Tue, 11 Apr 2006 01:02:43 -0700 (PDT)
Message-ID: <20060411.010243.132136674.davem@davemloft.net>
References: <200604101716.58463.vda@ilport.com.ua>
	<1144682807.12177.22.camel@dillow.idleaire.com>
	<200604111028.54813.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932348AbWDKIC7@vger.kernel.org>
To: vda@ilport.com.ua
In-Reply-To: <200604111028.54813.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Vlasenko <vda@ilport.com.ua>
Date: Tue, 11 Apr 2006 10:28:54 +0300

> But it saves some text (~5k total in all network drivers)
> and removes a branch on rx path on non-VLAN enabled kernels...

It removes "5K total" when you build every single networking driver
statically into the main kernel image.

Nobody does that except for build sanity testing.  Folks will
enable the drivers they need for their testing into a static
kernel, or build all the net drivers they want modular.

Please resist the urge to work on things like this in a robotic
fashion.  Consider whether the thing you're working on really matters
in real life, and whether the alternative you're providing is really
an overall improvement.  In this case you're "improving" a case only
kernel build testers will use, and the amount of ifdef's added by
your patches uglify the code immensely.  To me, that's a clear net
loss.
