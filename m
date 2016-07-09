From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 6/9] net: dsa: mv88e6xxx: rework Switch MAC
 setter
Date: Fri, 8 Jul 2016 20:03:15 -0400 (EDT)
Message-ID: <2075477569.472619.1468022595798.JavaMail.zimbra@savoirfairelinux.com>
References: <20160707125758.1547-1-vivien.didelot@savoirfairelinux.com> <20160707125758.1547-7-vivien.didelot@savoirfairelinux.com> <20160707135253.GO19800@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	David <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43560 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756290AbcGIADT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 20:03:19 -0400
In-Reply-To: <20160707135253.GO19800@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Jul 7, 2016, at 9:52 AM, Andrew Lunn andrew@lunn.ch wrote:

>> Also, note that this indirect access is a single-register which doesn't
>> require to wait for the operation to complete (like Switch MAC, Trunk
>> Mapping, etc.), in contrary to multi-registers indirect accesses with
>> several busy operations (like ATU, VTU, etc.).
> 
> Are you sure about this? The DSDT polls bit 15 of the register.

Every single-register operation (with an "Update" bit, "pointer" and "data"
bits) execute in a single write operation and doesn't need to wait for
completion.

But multiple-register operations like ATU, VTU, etc. with a "Busy" bit,
Operation bits and data registers, do require and explicitly mention to wait
for the operation to complete (by polling the busy bit or via interrupt).

We could add checks but it doesn't sound necessary, we are not doing it for
others Update operations and a badly set switch MAC address would be easily
identifiable.

Thanks,

	Vivien
