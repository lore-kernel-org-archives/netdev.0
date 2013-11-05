From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH] net: mv643xx_eth: Add missing phy_addr_set in DT mode
Date: Wed, 06 Nov 2013 00:14:34 +0100
Message-ID: <87iow6cug5.fsf@natisbad.org>
References: <1383611239-14556-1-git-send-email-jgunthorpe@obsidianresearch.com>
	<87sivacxcf.fsf@natisbad.org> <52796E82.5010800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52796E82.5010800@gmail.com> (Sebastian Hesselbarth's message of
	"Tue, 05 Nov 2013 23:17:38 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com> writes:

> On 11/05/2013 11:12 PM, Arnaud Ebalard wrote:
>> Hi Jason,
>>
>> Jason Gunthorpe <jgunthorpe@obsidianresearch.com> writes:
>>
>>> Commit cc9d4598 'net: mv643xx_eth: use of_phy_connect if phy_node
>>> present' made the call to phy_scan optional, if the DT has a link to
>>> the phy node.
>>>
>>> However phy_scan has the side effect of calling phy_addr_set, which
>>> writes the phy MDIO address to the ethernet controller. If phy_addr_set
>>> is not called, and the bootloader has not set the correct address then
>>> the driver will fail to function.
>>
>> Thanks *a lot* for fixing this one! I had the issue on my ReadyNAS 102
>> (Armada 370 based) which I had put on a todo list and temporarily
>
> Erm, just to make sure: Armada 370 isn't using mv643xx_eth but mvneta,
> are you sure it is (was) related to Jason's fix?

Thanks for pointing this, Sebastian and my apologies for the noise.
Jason's fix is indeed for a file which is not compiled for my RN102.

As the problem perfectly matched the issue I had and current kernel w/
the patch applied does indeed fix it, I did not try and do the test w/o
the patch applied. It would have showed the problem was fixed by
something else in 3.12. Well, I spent some time digging the changes on
mvneta.c and: 

commit 714086029116b6b0a34e67ba1dd2f0d1cf26770c
Author: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date:   Wed Sep 4 16:21:18 2013 +0200

    net: mvneta: properly disable HW PHY polling and ensure adjust_link() works
    
    This commit fixes a long-standing bug that has been reported by many
    users: on some Armada 370 platforms, only the network interface that
    has been used in U-Boot to tftp the kernel works properly in
    Linux. The other network interfaces can see a 'link up', but are
    unable to transmit data. The reports were generally made on the Armada
    370-based Mirabox, but have also been given on the Armada 370-RD
    board.

    [SNIP]

$ git tag --contains 714086029116
v3.12
v3.12-rc1
v3.12-rc2
v3.12-rc3
v3.12-rc4
v3.12-rc5
v3.12-rc6
v3.12-rc7

So the problem was indeed fixed at the beginning of 3.12 series by Thomas.

Anyway, my bad and thanks again for pointing it out.

Cheers,

a+
