From: =?UTF-8?B?T3J0d2luIEdsw7xjaw==?= <odi@odi.ch>
Subject: Re: xfrm: is pmtu broken with ESP tunneling?
Date: Thu, 13 Feb 2014 20:53:21 +0100
Message-ID: <52FD22B1.4070301@odi.ch>
References: <52F890D2.2060109@odi.ch> <20140211023258.GC11150@order.stressinduktion.org> <52FA8618.5030509@odi.ch> <20140213000115.GH11150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140213000115.GH11150@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/13/2014 01:01 AM, Hannes Frederic Sowa wrote:
> Could you try either dropwatch or perf script net_dropmonitor and flood the
> network with the problematic packets. From the traces we could see where the
> packets get dropped without notification in the kernel.

Not much to see, unfortunately. The COUNT doesn't reflect the number packets 
that I am missing.

                  LOCATION                    OFFSET                     COUNT 

      ieee80211_iface_work                       208                         1

> Strange that the problem disappears if you enable no_pmtu_disc then.

It seems with PMTU the initial mtu is the one of the device (1500). So the 
original packet will have that size, but is subsequently wrapped into ESP and 
UDP, which add to that size. And the final packet is then larger than the device 
MTU... I know nothing about the ip / xfrm kernel code, so it's hard for me to 
verify if that theory is real.

Thanks,

Ortwin
