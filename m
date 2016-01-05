From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: Re: [PATCH] rt2x00pci: Disable memory-write-invalidate when the driver
 exits
Date: Tue, 05 Jan 2016 09:27:47 +0800
Message-ID: <568B1C13.9050900@163.com>
References: <1451894138-3482-1-git-send-email-baijiaju1990@163.com> <CAGXE3d9tTr6hyOjh==Mn5tNQSy-hMBhxtmsWNY_tLgJqE=B38A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>, kvalo@codeaurora.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:47350 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753681AbcAEB2P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 20:28:15 -0500
In-Reply-To: <CAGXE3d9tTr6hyOjh==Mn5tNQSy-hMBhxtmsWNY_tLgJqE=B38A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2016 12:50 AM, Helmut Schaa wrote:
> On Mon, Jan 4, 2016 at 8:55 AM, Jia-Ju Bai<baijiaju1990@163.com>  wrote:
>> The driver calls pci_set_mwi to enable memory-write-invalidate when it
>> is initialized, but does not call pci_clear_mwi when it is removed. Many
>> other drivers calls pci_clear_mwi when pci_set_mwi is called, such as
>> r8169, 8139cp and e1000.
>>
>> This patch adds pci_clear_mwi in error handling and removal procedure,
>> which can fix the problem.
>>
>> Signed-off-by: Jia-Ju Bai<baijiaju1990@163.com>
> Looks good to me.
> Does this fix any actual issue?
> If yes it might we worth to mention it in the commit message.
> Helmut
>

Lacking pci_clear_mwi may cause a resource-release omission,
but this omission may not cause obvious issues.
For reliability, it is better to add pci_clear_mwi in the driver.
Many other drivers do so, such as r8169, 8139cp and e1000.


Jia-Ju Bai
