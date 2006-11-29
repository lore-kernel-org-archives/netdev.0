From: Andrew Morton <akpm@osdl.org>
Subject: Re: Bug 7596 - Potential performance bottleneck for Linxu TCP
Date: Wed, 29 Nov 2006 15:42:00 -0800
Message-ID: <20061129154200.c4db558c.akpm@osdl.org>
References: <HNEBLGGMEGLPMPPDOPMGKEAJCGAA.wenji@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:63710 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S934499AbWK2XmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 18:42:06 -0500
To: wenji@fnal.gov
In-Reply-To: <HNEBLGGMEGLPMPPDOPMGKEAJCGAA.wenji@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Nov 2006 17:22:10 -0600
Wenji Wu <wenji@fnal.gov> wrote:

> From: Wenji Wu <wenji@fnal.gov>
> 
> Greetings,
> 
> For Linux TCP, when the network applcaiton make system call to move data
> from
> socket's receive buffer to user space by calling tcp_recvmsg(). The socket
> will
> be locked. During the period, all the incoming packet for the TCP socket
> will go
> to the backlog queue without being TCP processed. Since Linux 2.6 can be
> inerrupted mid-task, if the network application expires, and moved to the
> expired array with the socket locked, all the packets within the backlog
> queue
> will not be TCP processed till the network applicaton resume its execution.
> If
> the system is heavily loaded, TCP can easily RTO in the Sender Side.
> 
> Attached is the detailed description of the problem and one possible
> solution.

Thanks.  The attachment will be too large for the mailing-list servers so I
uploaded a copy to
http://userweb.kernel.org/~akpm/Linux-TCP-Bottleneck-Analysis-Report.pdf

>From a quick peek it appears that you're getting around 10% improvement in
TCP throughput, best case.

