From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Wed, 9 Mar 2005 11:24:44 -0600
Message-ID: <57a429f8eb807987d88b06129861d507@freescale.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com> <1110334456.32556.21.camel@gaston> <20050308194229.41c23707.davem@davemloft.net> <1110340214.32524.32.camel@gaston>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        linuxppc-embedded@ozlabs.org
In-Reply-To: <1110340214.32524.32.camel@gaston>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mar 8, 2005, at 21:50, Benjamin Herrenschmidt wrote:

> On Tue, 2005-03-08 at 19:42 -0800, David S. Miller wrote:
>> On Wed, 09 Mar 2005 13:14:16 +1100
>> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
>>
>>> I'll have a closer look when I find some time, see if it makes sense 
>>> to
>>> adapt sungem or not.
>>
>> Especially because of the Broadcom PHYs I bet it doesn't.
>>
>> Too many chips have to reset the MAC, or do other fancy stuff
>> when programming the PHY to make this genphy thing very useful.
>
> Oh, I think genphy is just a generic driver, but his layer has hooks 
> for
> other PHY drivers (wasn't it based on sungem_phy in the first place ?)

Definitely.  Much of this code was culled from the sungem and ibm_emac 
drivers, with some input from mii.c.  The genphy driver is just one of 
the 6 PHY drivers in the patch I sent (the others are Marvell, Davicom, 
Cicada, QS, LXT).  Actually, several of those files have multiple 
drivers in them.  The genphy driver is the fallback driver.  It exists 
for those PHYs which never get a driver, but don't need special 
attention.

>
> I discussed several steps of the design with Andy, the idea was to have
> something a bit like sungem_phy.c with addditional common library for
> doing the link polling & fallback stuff etc... that could be easily
> shared by drivers.

Yup.  I look forward to your input on how well the code meshes with 
what people need for their drivers.
