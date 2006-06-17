From: Andrew Morton <akpm@osdl.org>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Sat, 17 Jun 2006 15:35:11 -0700
Message-ID: <20060617153511.53a129a3.akpm@osdl.org>
References: <4492D5D3.4000303@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48584 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751017AbWFQWfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2006 18:35:18 -0400
To: Harry Edmon <harry@atmos.washington.edu>
In-Reply-To: <4492D5D3.4000303@atmos.washington.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Jun 2006 09:01:23 -0700
Harry Edmon <harry@atmos.washington.edu> wrote:

> I have a system with a strange network performance degradation from 
> 2.6.11.12 to most recent kernels including 2.6.16.20 and 2.6.17-rc6.   
> The system is has Dual single core Xeons with hyperthreading on.   The 
> application is the LDM system from UCAR/Unidata 
> (http://www.unidata.ucar.edu/software/ldm).   This system requests 
> weather data from a variety of systems using RPC calls over a reserved 
> TCP port (388), puts them into a memory mapped queue file, and then 
> sends the data out to a variety of downstream requesting systems, again 
> using RPC calls.  When the load is heavy, the 2.6.16.20 kernel falls way 
> behind with the data ingestion.  The 2.6.11.12 kernel does not.   I have 
> tried an experiment with a 2.6.17-rc6 system where it just does the 
> ingestion, and not the downstream distribution, and it is able to keep 
> up.   I would really appreciate any pointers as to where the problem may 
> be and how to diagnose it.  I have attached the config files from both 
> kernels and the sysctl.conf file I am using.   I have also included the 
> output from "netstat -s" on the 2.6.16.20 system during a time when it 
> was having problems.
> 

(added netdev)

A quick grep indicates that it isn't using TCP_NODELAY - we've had problems
with that in the past.

Perhaps a tcpdump of the net traffic will help to determine what's going on.
