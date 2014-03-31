From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Handle null return by pci_match_id()
Date: Mon, 31 Mar 2014 09:29:52 +0300
Message-ID: <53390B60.4000600@gmail.com>
References: <1396193215-6863-1-git-send-email-amirv@mellanox.com>	<CAJZOPZ+je04BC8BAoL1i1jAGrMFbHkFSAjypFSd3Kxc6_PC-cw@mail.gmail.com>	<20140331035439.GA11288@richard> <CAJZOPZKOPHDoBDSd7=ytbC8MfPPD_ZKBh6qrc0iA+mRF+FD6DQ@mail.gmail.com>
Reply-To: amirv@mellanox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>
To: Or Gerlitz <or.gerlitz@gmail.com>,
	Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:56740 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbaCaGaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 02:30:01 -0400
Received: by mail-wi0-f174.google.com with SMTP id d1so2683142wiv.7
        for <netdev@vger.kernel.org>; Sun, 30 Mar 2014 23:30:00 -0700 (PDT)
In-Reply-To: <CAJZOPZKOPHDoBDSd7=ytbC8MfPPD_ZKBh6qrc0iA+mRF+FD6DQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/31/2014 7:52 AM, Or Gerlitz wrote:
> On Mon, Mar 31, 2014 at 6:54 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>>
>> On Sun, Mar 30, 2014 at 09:08:06PM +0300, Or Gerlitz wrote:
>>> On Sun, Mar 30, 2014 at 6:26 PM, Amir Vadai <amirv@mellanox.com> wrote:
>>>> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
>>>> pci_device_id.driver_data to __mlx4_init_one during reset".
>>>>
>>>> pci_match_id() might return NULL if someone binds the driver to a device
>>>> manually using /sys/bus/pci/drivers/.../new_id. Need to check 'id'
>>>> before using it.
>>>>
>>>> Thanks to Bjorn who raised the problem.
>>>
>>> Well, that commit was applied to net and is now present in Linus
>>> tree... so assuming it's too late for 3.14, need to queue this for
>>> -stable
>>>
>>> Or.
>>
>> Sorry for this bothering, hope this will not block someone.
>>
>> Here is my suggestion for fixing this, not sure this is a good way to export
>> pci_match_device() to modules. This is my current solution to this problem. If
>> you have any comments, please let me know.
>>
>> ------------------------------------------------------------------------------
>>  From 9361e1edd6776202c6e11dd44d3d4d72c990b111 Mon Sep 17 00:00:00 2001
>> From: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Date: Mon, 31 Mar 2014 11:34:57 +0800
>> Subject: [PATCH net-next] net/mlx4_core: match pci_device_id including dynids
>
>
>
> Your original commit went to net and same needs to be done for the fix
>
>
>
>>
>>
>> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
>> pci_device_id.driver_data to __mlx4_init_one during reset".
>>
>> pci_match_id() just match the static pci_device_id, which may return NULL if
>> someone binds the driver to a device manually using
>> /sys/bus/pci/drivers/.../new_id.
>>
>> This patch match pci_device_id with pci_match_device() to cover both dynids
>> and static id_table.
>>
>> Thanks to Bjorn finding this issue.
>>
>> CC: Bjorn Helgaas <bhelgaas@google.com>
>> CC: Amir Vadai <amirv@mellanox.com>
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

Acked-By: Amir Vadai <amirv@mellanox.com>

And of-course need to fix the net/net-next/stable thing
