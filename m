From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH] Bluetooth: Revert "Bluetooth: rfcomm: Remove unnecessary
 krfcommd event"
Date: Wed, 29 Oct 2014 22:06:17 -0400
Message-ID: <54519D19.6070205@hurleysoftware.com>
References: <1414632736-18782-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>, marcel@holtmann.org,
	gustavo@padovan.org, johan.hedberg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414632736-18782-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sasha,

On 10/29/2014 09:32 PM, Sasha Levin wrote:
> This reverts commit e5842cdb0f4f2c68f6acd39e286e5d10d8c073e8.
> 
> We can't call rfcomm_process_sessions() while our task state is not
> TASK_RUNNING since rfcomm_process_sessions() tries to lock mutexes
> and sleep. The scheduler even complains about it:
> 
> [   21.683959] WARNING: CPU: 13 PID: 8165 at kernel/sched/core.c:7305 __might_sleep+0xe5/0x1b0()
> [   21.683962] do not call blocking ops when !TASK_RUNNING; state=1 set at rfcomm_run (net/bluetooth/rfcomm/core.c:2096)

This problem is in-process with Peter Z and Oleg and a new api
for handling nested sleeps.

The thread is here
http://www.gossamer-threads.com/lists/linux/kernel/2019181?do=post_view_threaded
and the reminder thread here
https://lkml.org/lkml/2014/10/27/343

Regards,
Peter Hurley
