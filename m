From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 0/2] introduce devm_mdiobus_alloc/devm_mdiobus_free
Date: Fri, 11 Apr 2014 14:05:25 +0300
Message-ID: <5347CC75.8040300@ti.com>
References: <1396618825-4241-1-git-send-email-grygorii.strashko@ti.com>
	<CAGVrzcZ8vXBn4omyR7+ejihhcrspt-Rz_BBh55esxNFO06gHgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dlos <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        "linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <santosh.shilimkar-l0cyMroinI0@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Jonathan
 Cameron <jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <CAGVrzcZ8vXBn4omyR7+ejihhcrspt-Rz_BBh55esxNFO06gHgQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Florian,
On 04/11/2014 07:55 AM, Florian Fainelli wrote:
> Hi Grygorii,
> 
> 2014-04-04 6:40 GMT-07:00 Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>:
>> Introduce a resource managed devm_mdiobus_alloc()/devm_mdiobus_free()
>> to automatically clean up MDIO bus alocations made by MDIO drivers,
>> thus leading to simplified MDIO drivers code.
>>
>> Update Davinci MDIO driver ss example of new devm APIs usage.
> 
> This does look good at first glance. net-next is currently closed at
> the moment, so this will have to be merged later.

Thanks. It can wait for 3.16, so I'll update & resend after rc1.
I have few more patches for davinci_mdio.c, so
my intention here was to check if I can base them on top of new API or not :)

> 
> At some point, we might also want to handle the mdio_bus irq array, as
> that one is also usually dynamically allocated. Maybe we could just do
> a static irq[PHY_MAX_ADDR] allocation, 32 times the size of an integer
> might not be worth a potential leak.

It sounds good, but first of all irq field of mii_bus structure has to be made private. 
And drivers have to use getter/setters to access it - then its type can be changes 
simply and safely.

By the way, mdiobus_register() can be handled using DEVM approach too, but it 
will a bit more complex.

[...]
> 

Regards,
- grygorii
