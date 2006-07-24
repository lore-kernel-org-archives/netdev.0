From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Problems with sky2 driver.
Date: Mon, 24 Jul 2006 11:45:33 -0700
Message-ID: <20060724114533.2c61992b@dxpl.pdx.osdl.net>
References: <20060724133829.49bf7979@akemi>
	<20060724105303.2c4d529f@localhost.localdomain>
	<20060724143839.56bfebdb@akemi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43744 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751417AbWGXSp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 14:45:27 -0400
To: Todd Showalter <tshowalter@silverbirchstudios.com>,
	netdev@vger.kernel.org
In-Reply-To: <20060724143839.56bfebdb@akemi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Jul 2006 14:38:39 -0400
Todd Showalter <tshowalter@silverbirchstudios.com> wrote:

> On Mon, 24 Jul 2006 10:53:03 -0700, Stephen Hemminger
> <shemminger@osdl.org> wrote:
> 
> > There is a receive problem that shows up under load, that is fixed
> > in the latest version (2.6.18 git), the patch is queued for the stable
> > tree as well.
> 
>     I have hand-patched this in my 2.6.17.6 kernel.  It seems better
> (no hard wedge yet), but there are still definitely problems.
> 
>     The most obvious place is in firefox; for example, the front page
> of slashdot half-renders (all the borders, no stories) and then sits
> "loading" for eternity.  Ditto the online package database at
> gentoo.org.  I'm seeing similar behavior with other websites as well.
> It's consistant, too; I haven't been able to view the slashdot front
> page since booting a 2.6.17 kernel.


I suspect that probably isn't a sky2 driver problem.
Does it go away if you turn of TCP window scaling:
	sysctl -w net.ipv4.tcp_window_scaling=0

If so, you probably have a middlebox in your path that is not correctly
handling TCP window scaling. OpenBSD seems to be particularly bad.

> 
>     If I boot with the 2.6.16.9 kernel, I don't seem to get that
> problem until the network actually hangs.
> 
>                                                Todd.
> 
> --
>   Todd Showalter
>   Silverbirch Studios


-- 
Stephen Hemminger <shemminger@osdl.org>
"And in the Packet there writ down that doome"
