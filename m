From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] tg3: fix VLAN tagging regression
Date: Tue, 20 Sep 2011 14:27:29 -0700
Message-ID: <CAEP_g=9V=5zHqwz710TSuRSqTdo1kqkKF2VEEV6K3Tv1zupegg@mail.gmail.com>
References: <4E78FC38.7040903@kasperkp.dk> <20110920210929.GA9652@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kasper Pedersen <kernel@kasperkp.dk>,
	Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110920210929.GA9652@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2011 at 2:09 PM, Matt Carlson <mcarlson@broadcom.com> w=
rote:
> On Tue, Sep 20, 2011 at 01:48:56PM -0700, Kasper Pedersen wrote:
>> commit 92cd3a17ce9c719abb4c28dee3438e0c641f8de4
>> =C2=A0 =C2=A0 tg3: Simplify tx bd assignments
>>
>> broke VLAN tagging on outbound packets.
>> It ifdef'ed BCM_KERNEL_SUPPORTS_8021Q, but this
>> is not set anywhere. So vlan never gets set, and
>> all packets are sent with vlan=3D0.
>>
>> Change to use the CONFIG_VLAN_xxx defines instead.
>> Tested on BCM5721 rev 11.
>>
>> Signed-off-by: Kasper Pedersen <kernel@kasperkp.dk>
>
> Yes. =C2=A0This is correct.
>
> Acked-by: Matt Carlson <mcarlson@broadcom.com>

Actually, please don't do this.  Those config #define's refer to the
802.1q module that creates vlan devices only.  The rest of the network
stack has code for dealing with vlan packets that is not protected by
config guards, so there's no reason that drivers should be.  The
correct thing to do here is just drop the test altogether and
unconditionally include the code.
