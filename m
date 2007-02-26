From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: netconsole module cannot be removed
Date: Mon, 26 Feb 2007 18:07:48 -0500
Message-ID: <45E36844.5040402@redhat.com>
References: <45E3447F.9080706@redhat.com> <20070226133156.3bfd2a74@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740AbXBZXYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 18:24:07 -0500
In-Reply-To: <20070226133156.3bfd2a74@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Mon, 26 Feb 2007 15:35:11 -0500
> Chuck Ebbert <cebbert@redhat.com> wrote:
> 
>> Trying to remove netconsole, rmmod goes into a tight loop with
>> 100% CPU usage. It can't be killed with 'kill -9'. Shutdown
>> works, though. Kernel is 2.6.20 FC6 config, and I'm 99.9%
>> sure the module signing has nothing to do with this.
>>
> 
> No it probably has to do with printing a message during module removal.
> 

Works fine in 2.6.19.5

Hangs in vanilla 2.6.20 in netpoll_cleanup()

Call trace: 
 flush_cpu_workqueue
 flush_workqueue
 cancel_rearming_delayed_workqueue
 netpoll_cleanup
 sys_delete_module

It varies, but is always in one of the first three functions when you
do alt-sysrq-p.

