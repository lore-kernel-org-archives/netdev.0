From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: tg3: link is permanently down after ifdown and ifup
Date: Sat, 21 Nov 2009 13:03:39 +0200
Message-ID: <4B07C90B.5060708@embedded-sol.com>
References: <4B056158.5060104@embedded-sol.com>	<4B056D85.5010904@embedded-sol.com>
	<1258671053.14964.20.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, mcarlson@broadcom.com,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1258671053.14964.20.camel@nseg_linux_HP1.broadcom.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Hi,

Michael Chan wrote:
> On Thu, 2009-11-19 at 08:08 -0800, Felix Radensky wrote:
>   
>> Hi,
>>
>> The problem goes away if I remove the call to
>>
>> tg3_set_power_state(tp, PCI_D3hot);
>>
>> from tg3_close().
>>     
>
> Added Matt to CC.  He is on vacation and may not be able to look into
> this right away.  Thanks.
>
>   
Thanks, Michael. After digging some more into it, I've found that the
problem is in tg3_power_down_phy() routine. Apparently 57780 PHY
is not handled properly. If tg3_power_down_phy() is not invoked from
tg3_set_power_state(), the problem is not reproducible anymore. I don't
have enough information about  NIC internals to dig further.

Felix.
