From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH] Fix e1000e with Intel 82572EI that has no hardware timestamp
 support
Date: Wed, 06 Aug 2014 12:09:17 -0300
Message-ID: <1407337757.772491.149802333.5E523CB0@webmail.messagingengine.com>
References: <be459158bb5c46fcaf73129858342da4@FE-MBX1012.de.bosch.com>
 <53E23BEF.9030701@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Koehrer Mathias <mathias.koehrer@etas.com> (ETAS/ESW5),
	Nick Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53E23BEF.9030701@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 6, 2014, at 11:30, Sergei Shtylyov wrote:
> On 8/6/2014 6:27 PM, Koehrer Mathias (ETAS/ESW5) wrote:
> 
> > With the Intel 82527EI (driver: e1000e) there is an issue when running
> > the ptpd2 program, that leads to a kernel oops.
> > The reason is here that in e1000_xmit_frame() a work queue will be
> > scheduled that has not been initialized in this case.
> > The work queue "tx_hwstamp_work" will only be initialized if
> > adapter->flags & FLAG_HAS_HW_TIMESTAMP set.
> > This check is missing in e1000_xmit_frame().
> 
> > The following patch adds the missing check.
> 
>     OK, but this time you forgot your sign-off. :-)

Also, shouldn't the added test be inside the unlikely() ?

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
