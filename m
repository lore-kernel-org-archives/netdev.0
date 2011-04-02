From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Support e1000 M88 PHY registers in -d
Date: Sat, 02 Apr 2011 17:24:01 +0100
Message-ID: <1301761441.10056.197.camel@localhost>
References: <20100319043229.24908.99968.reportbug@Feynman.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	574574@bugs.debian.org
To: Anthony DeRobertis <anthony@derobert.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100319043229.24908.99968.reportbug@Feynman.home>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Anthony,

I'm now upstream maintainer for ethtool so I've picked up your patch
again.

On Fri, 2010-03-19 at 00:32 -0400, Anthony DeRobertis wrote:
> Package: ethtool
> Version: 1:2.6.33-1
> Severity: wishlist
> 
> The M88 PHY registers contain useful information like the cable length
> estimate and the MDI/MDIX status. The attached patch makes -d dump
> them.

Patches for ethtool should include a commit message and Signed-off-by
line, as in the Linux kernel.  See sections 2 and 12 of
<http://www.kernel.org/doc/Documentation/SubmittingPatches>.  They
should be sent to this address and to netdev.

I'm forwarding this patch to netdev and the e1000 developers for review.

Ben.

[...]
> diff -rdbU3 ethtool-2.6.33/e1000.c ethtool-2.6.33.new//e1000.c
> --- ethtool-2.6.33/e1000.c      2009-02-08 18:52:12.000000000 -0500
> +++ ethtool-2.6.33.new//e1000.c 2010-03-19 00:26:33.044052610 -0400
> @@ -110,6 +110,61 @@
>  #define E1000_TCTL_RTLC   0x01000000    /* Re-transmit on late collision */
>  #define E1000_TCTL_NRTU   0x02000000    /* No Re-transmit on underrun */
>  
> +/* M88E1000 PHY Specific Status Register */
> +#define M88_PSSR_JABBER             0x0001 /* 1=Jabber */
> +#define M88_PSSR_REV_POLARITY       0x0002 /* 1=Polarity reversed */
> +#define M88_PSSR_DOWNSHIFT          0x0020 /* 1=Downshifted */
> +#define M88_PSSR_MDIX               0x0040 /* 1=MDIX; 0=MDI */
> +#define M88_PSSR_CABLE_LENGTH       0x0380 /* 0=<50M;1=50-80M;2=80-110M;
> +                                            * 3=110-140M;4=>140M */
> +#define M88_PSSR_LINK               0x0400 /* 1=Link up, 0=Link down */
> +#define M88_PSSR_SPD_DPLX_RESOLVED  0x0800 /* 1=Speed & Duplex resolved */
> +#define M88_PSSR_PAGE_RCVD          0x1000 /* 1=Page received */
> +#define M88_PSSR_DPLX               0x2000 /* 1=Duplex 0=Half Duplex */
> +#define M88_PSSR_SPEED              0xC000 /* Speed, bits 14:15 */
> +#define M88_PSSR_10MBS              0x0000 /* 00=10Mbs */
> +#define M88_PSSR_100MBS             0x4000 /* 01=100Mbs */
> +#define M88_PSSR_1000MBS            0x8000 /* 10=1000Mbs */
> +
> +#define M88_PSSR_CL_0_50     (0<<7)
> +#define M88_PSSR_CL_50_80    (1<<7)
> +#define M88_PSSR_CL_80_110   (2<<7)
> +#define M88_PSSR_CL_110_140  (3<<7)
> +#define M88_PSSR_CL_140_PLUS (4<<7)
> +
> +/* M88E1000 PHY Specific Control Register */
> +#define M88_PSCR_JABBER_DISABLE    0x0001  /* 1=Jabber Function disabled */
> +#define M88_PSCR_POLARITY_REVERSAL 0x0002  /* 1=Polarity Reversal enabled */
> +#define M88_PSCR_SQE_TEST          0x0004  /* 1=SQE Test enabled */
> +#define M88_PSCR_CLK125_DISABLE    0x0010  /* 1=CLK125 low,
> +                                            * 0=CLK125 toggling
> +                                            */
> +#define M88_PSCR_MDI_MASK         0x0060
> +#define M88_PSCR_MDI_MANUAL_MODE  0x0000   /* MDI Crossover Mode bits 6:5 */
> +                                          /* Manual MDI configuration */
> +#define M88_PSCR_MDIX_MANUAL_MODE 0x0020   /* Manual MDIX configuration */
> +#define M88_PSCR_AUTO_X_1000T     0x0040   /* 1000BASE-T: Auto crossover,
> +                                            *  100BASE-TX/10BASE-T:
> +                                            *  MDI Mode
> +                                            */
> +#define M88_PSCR_AUTO_X_MODE      0x0060   /* Auto crossover enabled
> +                                            * all speeds.
> +                                            */
> +#define M88_PSCR_10BT_EXT_DIST_ENABLE 0x0080
> +                                   /* 1=Enable Extended 10BASE-T distance
> +                                    * (Lower 10BASE-T RX Threshold)
> +                                    * 0=Normal 10BASE-T RX Threshold */
> +#define M88_PSCR_MII_5BIT_ENABLE      0x0100
> +                                   /* 1=5-Bit interface in 100BASE-TX
> +                                    * 0=MII interface in 100BASE-TX */
> +#define M88_PSCR_SCRAMBLER_DISABLE    0x0200       /* 1=Scrambler disable */
> +#define M88_PSCR_FORCE_LINK_GOOD      0x0400       /* 1=Force link good */
> +#define M88_PSCR_ASSERT_CRS_ON_TX     0x0800       /* 1=Assert CRS on Transmit */
> +
> +#define M88_PSCR_POLARITY_REVERSAL_SHIFT    1
> +#define M88_PSCR_AUTO_X_MODE_SHIFT          5
> +#define M88_PSCR_10BT_EXT_DIST_ENABLE_SHIFT 7
> +
>  /* PCI Device IDs */
>  #define E1000_DEV_ID_82542                    0x1000
>  #define E1000_DEV_ID_82543GC_FIBER            0x1001
> @@ -515,6 +570,72 @@
>                 regs_buff[12] == 1 ? "IGP" :
>                 regs_buff[12] == 2 ? "IGP2" : "unknown" );
>  
> +       if (0 == regs_buff[12]) {
> +               reg = regs_buff[13];
> +               fprintf(stdout,
> +                       "M88 PHY STATUS REGISTER:                 0x%08X\n"
> +                       "      Jabber:                            %s\n"
> +                       "      Polarity:                          %s\n"
> +                       "      Downshifted:                       %s\n"
> +                       "      MDI/MDIX:                          %s\n"
> +                       "      Cable Length Estimate:             %s meters\n"
> +                       "      Link State:                        %s\n"
> +                       "      Speed & Duplex Resolved:           %s\n"
> +                       "      Page Received:                     %s\n"
> +                       "      Duplex:                            %s\n"
> +                       "      Speed:                             %s mbps\n",
> +                       reg,
> +                       reg & M88_PSSR_JABBER       ? "yes"     : "no",
> +                       reg & M88_PSSR_REV_POLARITY ? "reverse" : "normal",
> +                       reg & M88_PSSR_DOWNSHIFT    ? "yes"     : "no",
> +                       reg & M88_PSSR_MDIX         ? "MDIX"    : "MDI",
> +                       ((reg & M88_PSSR_CABLE_LENGTH)==M88_PSSR_CL_0_50 ? "0-50"
> +                               : (reg & M88_PSSR_CABLE_LENGTH)==M88_PSSR_CL_50_80 ? "50-80"
> +                               : (reg & M88_PSSR_CABLE_LENGTH)==M88_PSSR_CL_80_110 ? "80-110"
> +                               : (reg & M88_PSSR_CABLE_LENGTH)==M88_PSSR_CL_110_140? "110-140"
> +                               : (reg & M88_PSSR_CABLE_LENGTH)==M88_PSSR_CL_140_PLUS ? "140+"
> +                               : "unknown"),
> +                       reg & M88_PSSR_LINK              ? "Up"      : "Down",
> +                       reg & M88_PSSR_SPD_DPLX_RESOLVED ? "Yes"     : "No",
> +                       reg & M88_PSSR_PAGE_RCVD         ? "Yes"     : "No",
> +                       reg & M88_PSSR_DPLX              ? "Full"    : "Half",
> +                       ((reg & M88_PSSR_SPEED)==M88_PSSR_10MBS        ? "10"
> +                               : (reg & M88_PSSR_SPEED)==M88_PSSR_100MBS  ? "100"
> +                               : (reg & M88_PSSR_SPEED)==M88_PSSR_1000MBS ? "1000"
> +                               : "unknown")
> +               );
> +
> +               reg = regs_buff[17];
> +               fprintf(stdout,
> +                       "M88 PHY CONTROL REGISTER:                0x%08X\n"
> +                       "      Jabber funtion:                    %s\n"
> +                       "      Auto-polarity:                     %s\n"
> +                       "      SQE Test:                          %s\n"
> +                       "      CLK125:                            %s\n"
> +                       "      Auto-MDIX:                         %s\n"
> +                       "      Extended 10Base-T Distance:        %s\n"
> +                       "      100Base-TX Interface:              %s\n"
> +                       "      Scrambler:                         %s\n"
> +                       "      Force Link Good:                   %s\n"
> +                       "      Assert CRS on Transmit:            %s\n",
> +                       reg,
> +                       reg & M88_PSCR_JABBER_DISABLE    ? "disabled" : "enabled",
> +                       reg & M88_PSCR_POLARITY_REVERSAL ? "enabled"  : "disabled",
> +                       reg & M88_PSCR_SQE_TEST          ? "enabled"  : "disabled",
> +                       reg & M88_PSCR_CLK125_DISABLE    ? "disabled" : "enabled",
> +                       ((reg & M88_PSCR_MDI_MASK)==M88_PSCR_MDI_MANUAL_MODE ? "force MDI"
> +                               : (reg & M88_PSCR_MDI_MASK)==M88_PSCR_MDIX_MANUAL_MODE ? "force MDIX"
> +                               : (reg & M88_PSCR_MDI_MASK)==M88_PSCR_AUTO_X_1000T ? "1000 auto, 10/100 MDI"
> +                               : (reg & M88_PSCR_MDI_MASK)==M88_PSCR_AUTO_X_MODE ? "auto"
> +                               : "wtf"),
> +                       reg & M88_PSCR_10BT_EXT_DIST_ENABLE ? "enabled" : "disabled",
> +                       reg & M88_PSCR_MII_5BIT_ENABLE ? "5-bit" : "MII",
> +                       reg & M88_PSCR_SCRAMBLER_DISABLE ? "disabled" : "enabled",
> +                       reg & M88_PSCR_FORCE_LINK_GOOD ? "forced" : "disabled",
> +                       reg & M88_PSCR_ASSERT_CRS_ON_TX ? "enabled" : "disabled"
> +               );
> +       }
> +
>         return 0;
>  }
>   
-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
Create and publish websites with WebMatrix
Use the most popular FREE web apps or write code yourself; 
WebMatrix provides all the features you need to develop and 
publish your website. http://p.sf.net/sfu/ms-webmatrix-sf
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
