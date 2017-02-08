From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: dp83867: Fall-back to default values of clock
 delay and FIFO depth
Date: Wed, 8 Feb 2017 10:20:00 -0800
Message-ID: <360cfba0-cc84-4378-025d-34e5eb1fc2c8@gmail.com>
References: <20170206192445.35829-1-abrodkin@synopsys.com>
 <20170208.131519.1313210815958231832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com, andrew@lunn.ch,
 netdev@vger.kernel.org, nsekhar@ti.com, linux-kernel@vger.kernel.org,
 m-karicheri2@ti.com, linux-snps-arc@lists.infradead.org
To: David Miller <davem@davemloft.net>, Alexey.Brodkin@synopsys.com
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170208.131519.1313210815958231832.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 02/08/2017 10:15 AM, David Miller wrote:
> From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
> Date: Mon,  6 Feb 2017 22:24:45 +0300
> 
>> Given there're default values mentioned in the PHY datasheet
>> fall-back gracefully to them instead of silently return an error
>> through the whole call-chain.
>>
>> This allows to use minimalistic description in DT if no special
>> features are required.
>>
>> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
> 
> If these defaults are legitimate to use, then you should probably also
> set them in the non-CONFIG_OF_MDIO case implementation of
> dp83867_of_init().

IIRC this is what Alexey is doing already, in case of errors, instead of
returning the error code, he changes the default values and does not
propagate the error code.

Alexey, you are essentially making dp83867_of_init() impossible to fail
(or nearly) now, even with invalid properties, so I agree with David
here, you should probably have a function that runs after
dp83867_of_init() whose job is to set default values, if none have been
previously set through Device Tree.

> 
> But I'd like to see feedback and reviews from other PHY area experts
> before I even consider that updated version of this change.
> 
> Thanks.
> 


-- 
Florian
