From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tcp: efficient port randomisation (revised)
Date: Tue, 30 Nov 2004 21:46:43 -0800
Message-ID: <20041130214643.7b72300e.davem@davemloft.net>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>
	<200411020854.44745.michael.vittrup.larsen@ericsson.com>
	<20041104100104.570e67cd@dxpl.pdx.osdl.net>
	<200411051103.59032.michael.vittrup.larsen@ericsson.com>
	<20041117153025.160eaa04@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: michael.vittrup.larsen@ericsson.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041117153025.160eaa04@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Nov 2004 15:30:25 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Here is a more conservative version of earlier patch vthat keeps the
> same port rover locking and global port rover. This randomizes TCP
> ephemeral ports of incoming connections using variation of existing
> sequence number hash.
> 
> Thanks to original author Michael Larsen. 
> http://www.ietf.org/internet-drafts/draft-larsen-tsvwg-port-randomisation-00.txt
> 
> It behaves correctly if someone is perverse and sets low > high
> and it separates the outgoing port rover (tcp_port_rover) from the
> incoming port rover (start_rover).

I'm fine with this patch semantically.  What do the
before/after microbenchmarks look like?  We're adding
a MD4 transform plus a modulus for every local port
select operation.
