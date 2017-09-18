From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 6/6] Modify tag_ksz.c to support other KSZ switch
 drivers
Date: Mon, 18 Sep 2017 16:48:56 -0700
Message-ID: <c812edb6-9a8d-e8de-a288-3c2030b72bbd@gmail.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121901@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A22@CHN-SV-EXMX02.mchp-main.com>
 <20170907214834.GT11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D2E@CHN-SV-EXMX02.mchp-main.com>
 <20170918195708.GE15606@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D7C@CHN-SV-EXMX02.mchp-main.com>
 <20170918225142.GC29615@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124E0C@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com, andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41124E0C@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/18/2017 04:44 PM, Tristram.Ha@microchip.com wrote:
>>> In the old DSA implementation all the ports are partitioned into its own
>> device
>>> and the bridge joining them will do all the forwarding.  This is useful for
>> quick
>>> testing with some protocols like RSTP but it is probably useless for real
>>> operation.
>>
>> It is a good minimal driver, to get something into the kernel. You can
>> then add features to it.
>>
>>> The new switchdev model tries to use the switch hardware as much as
>>> possible.  This offload_fwd_mark bit means the frame is forwarded by the
>>> hardware switch, so the software bridge does not need to do it again.
>> Without
>>> this bit there will be duplicated multicast frames coming out the ports if
>> internal
>>> forwarding is enabled.
>>
>> Correct. Once you switch driver is clever enough, you can enable
>> offload_fwd_mark.
>>
>>> When RSTP is used the port can be put in blocked state and so the
>> forwarding
>>> will stop for that port.   Currently the switch driver will check that
>> membership
>>> to decide whether to set that bit.
>>
>> This i don't get. RSTP or STP just break loops. How does RSTP vs STP
>> mean you need to set offload_fwd_mark differently?
>>
> 
> The logic of the switch driver is if the membership of the port receiving
> the frame contains other ports--not counting cpu port--the bit
> offload_fwd_mark is set.  In RSTP closing the blocked port is generally good
> enough, but there are exceptions, so the port is removed from the
> membership of other forwarding ports.  A disabled port will have its
> membership completely reset so it cannot receive anything.  It does not
> matter much in RSTP as the software bridge should know whether to forward
> the frame or not.
> 
> We are back to square one.  Is there any plan to add this offload_fwd_mark
> support to DSA driver so that it can be reported properly?  It can be set all the
> time, except during port initialization or before bridge creation the forwarding
> state does not reflect reality.
> 
> If not the port membership can be fixed and there is no internal switch
> forwarding, leaving everything handled by the software bridge.

I am not really sure why this is such a concern for you so soon when
your driver is not even included yet. You should really aim for baby
steps here: get the basic driver(s) included, with a limited set of
features, and gradually add more features to the driver. When
fwd_offload_mark and RSTP become a real problem, we can most
definitively find a way to fix those in DSA and depending drivers.
-- 
Florian
