From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Wed, 25 Mar 2009 14:42:07 -0700 (PDT)
Message-ID: <20090325.144207.225365184.davem@davemloft.net>
References: <1237987849.2194.9.camel@gentoo-jocke.transmode.se>
	<49CA39EA.6020208@cosmosbay.com>
	<OF73F7C45F.ACAACBF8-ONC1257584.0052EC21-C1257584.0053E5EF@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, leoli@freescale.com,
	dada1@cosmosbay.com
To: Joakim.Tjernlund@transmode.se
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <OF73F7C45F.ACAACBF8-ONC1257584.0052EC21-C1257584.0053E5EF@transmode.se>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Wed, 25 Mar 2009 16:16:24 +0100

> UCC_GETH_DEV_WEIGHT needs to be a bit bigger than the number of RX
> HW buffers avaliable, otherwise one won't be able to drain the whole
> queue in one go. Changing weight to something bigger made a big
> difference.

You're not supposed to "drain the whole queue in one go", that
is not the goal of the weight value.

The goal of the weight value is that it is low enough such that
other devices also scheduled for NAPI on the current processor
can get some fair time to process packets too.
