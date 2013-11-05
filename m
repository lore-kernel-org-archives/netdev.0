From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: Add missing phy_addr_set in DT mode
Date: Tue, 05 Nov 2013 23:17:38 +0100
Message-ID: <52796E82.5010800@gmail.com>
References: <1383611239-14556-1-git-send-email-jgunthorpe@obsidianresearch.com> <87sivacxcf.fsf@natisbad.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Arnaud Ebalard <arno@natisbad.org>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87sivacxcf.fsf@natisbad.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/05/2013 11:12 PM, Arnaud Ebalard wrote:
> Hi Jason,
>
> Jason Gunthorpe <jgunthorpe@obsidianresearch.com> writes:
>
>> Commit cc9d4598 'net: mv643xx_eth: use of_phy_connect if phy_node
>> present' made the call to phy_scan optional, if the DT has a link to
>> the phy node.
>>
>> However phy_scan has the side effect of calling phy_addr_set, which
>> writes the phy MDIO address to the ethernet controller. If phy_addr_set
>> is not called, and the bootloader has not set the correct address then
>> the driver will fail to function.
>
> Thanks *a lot* for fixing this one! I had the issue on my ReadyNAS 102
> (Armada 370 based) which I had put on a todo list and temporarily

Erm, just to make sure: Armada 370 isn't using mv643xx_eth but mvneta,
are you sure it is (was) related to Jason's fix?

Sebastian

> workarounded by including a 'ping whatever' call in my u-boot env in
> order to force it to do the init. Without it, I was unable to properly
> use the interface. With your fix, after multiple reboots to test it,
> everything works as expected. So, FWIW:
>
> Tested-by: Arnaud Ebalard <arno@natisbad.org>
