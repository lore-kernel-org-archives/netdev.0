From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibmveth: Fix more little endian issues
Date: Tue, 24 Dec 2013 15:37:01 +1100
Message-ID: <1387859821.4373.10.camel@pasglop>
References: <1387762163-39662-1-git-send-email-agraf@suse.de>
 <20131223173833.0a9a6705@kryten> <1387810329.22671.66.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dinar Valeev <dvaleev@suse.com>,
 linuxppc-dev@lists.ozlabs.org, Alexander Graf <agraf@suse.de>,
 Anton Blanchard <anton@samba.org>, Santiago Leon <santil@linux.vnet.ibm.com>
To: Joe Perches <joe@perches.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1387810329.22671.66.camel@joe-AO722>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On Mon, 2013-12-23 at 06:52 -0800, Joe Perches wrote:
> On Mon, 2013-12-23 at 17:38 +1100, Anton Blanchard wrote:
> > The hypervisor expects MAC addresses passed in registers to be big
> > endian u64.
> 
> So maybe use __be64 declarations?
> 
> > +static unsigned long ibmveth_encode_mac_addr(char *mac)
> 
> static __be64 ibmveth_encode_mac_addr(const char *mac)

A register value has no endianness. Only memory content does. Especially
talking of a MAC address which is really a byte stream.... (Yes, our
__beXX types used without a * are borderline, but we've got used to it).

In fact I find the use of 

    memcpy(((char *)&encoded) + 2, mac, ETH_ALEN);

Really gross :-) Yes it works with the added cpu_to_be64() but in that
specific case, I think it would be nicer to simply load & shift into
position the 6 bytes and avoid the endianness issue completely.

Cheers,
Ben.
