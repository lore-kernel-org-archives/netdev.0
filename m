From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: Re: [PATCH 2/2] net/ibm/emac: fix size of emac dump memory areas
Date: Thu, 14 May 2015 16:04:34 +0400
Message-ID: <20150514160434.29ea2603@fr-ThinkPad-W520>
References: <20150512171200.207dfd7b@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150512171200.207dfd7b@fr-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 May 2015 17:12:00 +0400
Ivan Mikhaylov <ivan@ru.ibm.com> wrote:
>>On Tue, 2015-05-12 at 17:12 +0400, Ivan Mikhaylov wrote:
>> Fix in send of emac regs dump to ethtool which
>> causing wrong data interpretation on ethtool
>> layer for MII and EMAC.
>
>Please provide a better explanation. You removed the difference
>in register space size between EMAC and EMAC4, why ? You also changed a
>test regarding which version of the structure to use from EMAC4 to
>EMAC4SYNC, why ?

So, as I understand right, we have EMAC, EMAC4, EMAC4SYNC chips right now?
But within driver structure there are only EMAC4/EMAC4SYNC that I'm seeing or 
is it include and EMAC? I thought that only EMAC4/EMAC4SYNC we have. 

Anyway we have bug in ethtool, there size of emac_regs is defined and if we
will provide wrong size of emac_regs structure that will cause problems in
showing of some emac_regs fields for emac4sync + MII layer. Plus size of 
register space can be different on different platforms so because of this 
I removed macroses which doing this right from it. So just for example 
we have 0x100 for emac4sync in dts file, sizeof on ethtool is 152 always for 
emac_regs and we're reading MII values from emac area where is no data for
MII.

I have to add emac4sync support to ethtool regdump as I see in plus to
EMAC/EMAC4. What your opinion on this?
