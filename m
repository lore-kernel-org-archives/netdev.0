From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection hang problem with 2.6.16.16, e1000 (found work-around)
Date: Wed, 31 May 2006 14:45:13 -0700
Message-ID: <447E0E69.3080006@candelatech.com>
References: <447DC830.4080201@candelatech.com> <447DD870.80107@intel.com> <447DD9B5.9050100@candelatech.com> <447DF085.2050604@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:39614 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S965180AbWEaVpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 17:45:13 -0400
Received: from [71.112.216.116] (pool-71-112-216-116.sttlwa.dsl-w.verizon.net [71.112.216.116])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id k4VLjCSs006309
	for <netdev@vger.kernel.org>; Wed, 31 May 2006 14:45:12 -0700
In-Reply-To: <447DF085.2050604@candelatech.com>
To: unlisted-recipients:; (no To-header on input)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, I think I found the problem.  It appears to be at least partially
self-inflicted.  I was modifying the kernel buffer settings via /proc/*
to improve performance.  I noticed that when I used kernel-defaults,
the TCP connection hangs stopped (and ran ~20% slower).  My personal opinion
is that this is still a bug somewhere in TCP, but at least I have a work-around.

Since these settings appear somewhat delicate, it might be nice if
the kernel could warn about configurations that could cause TCP deadlocks
and such.

My old settings that exhibitted the problem were:

my $netdev_max_backlog = 5000;
my $wmem_max = 4096000;
my $wmem_default = 128000;
my $rmem_max = 8096000;
my $rmem_default = 128000;

my $tcp_rmem_min     = 4096;
my $tcp_rmem_default = 256000;
my $tcp_rmem_max     = 30000000;

my $tcp_wmem_min     = 4096;
my $tcp_wmem_default = 256000;
my $tcp_wmem_max     = 30000000;

my $tcp_mem_lo       = 20000000;
my $tcp_mem_pressure = 30000000;
my $tcp_mem_high     = 60000000;


The new settings that appear to work around the TCP connection hang,
and still give decent performance are below.  Documentation being thin,
I used the suggested values in Documentation/networking/ixgb.txt as
hints:

my $netdev_max_backlog = 30000;
my $wmem_max = 524287;
my $wmem_default = 128000;
my $rmem_max = 524287;
my $rmem_default = 128000;

my $tcp_rmem_min     = 4096;
my $tcp_rmem_default = 256000;
my $tcp_rmem_max     = 5000000;

my $tcp_wmem_min     = 4096;
my $tcp_wmem_default = 256000;
my $tcp_wmem_max     = 5000000;

my $tcp_mem_lo       = 10000000;
my $tcp_mem_pressure = 20000000;
my $tcp_mem_high     = 30000000;

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

