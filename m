From: Romain Perier <romain.perier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] stmmac: Don't exit mdio registration when mdio subnode is
 not found in the DTS
Date: Sun, 3 Jan 2016 15:36:06 +0100
Message-ID: <CABgxDo+EOVW-RJ1WVY+oHt1tbW7qq9Q_+wK3ywiexh+auEebaA@mail.gmail.com>
References: <1451397935-23643-1-git-send-email-romain.perier@gmail.com>
 <0E6F98A1-B9F1-48B0-B5CA-A215803E827F@gmail.com>
 <CABgxDoLNWEtYtRTrYhp7T=tk3n-aPMCgOP2SL7+DoxFqTk7GuQ@mail.gmail.com>
 <56880E46.4050206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
 "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <56880E46.4050206-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

2016-01-02 18:52 GMT+01:00 Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
>
>>> This looks reasonable, does it work if we just assign mdio_node to the pdev->dev.of_node to be backwards compatible with DTSes which have not yet been updated?
>>>
>>
>> I don't understand what you mean. Instead of defining mdio_node with
>> NULL, you propose to assign it to pdev->dev.of_node as its default
>> value... then it would be reassigned with "child_nod" if a subnode
>> with the compatible string "snps,dwmac-mdio" is found, or kept with
>> its default value otherwise... and in this case we could call
>> of_mdiobus_register(new_bus, mdio_node) all the time ? (it removes the
>> conditonnal branch)
>
> Your understanding is correct, this is what I was suggesting, thanks

So in this case, I already tested this yesterday, it does not work,
basically because the for loop just after of_mdiobus_register is never
executed, probably because new_bus->phy_map is not populated, which is
not the case by calling mdiobus_register for example.
of_mdiobus_register seems to populate this array of phys only for
subnodes found in the devicetree...

Regards,
Romain
