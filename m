From: Thayne Harbaugh <tharbaugh@lnxi.com>
Subject: Re: [PATCH] abysmal e1000 performance (DITR)
Date: Thu, 26 Aug 2004 15:28:57 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093555737.20769.135.camel@tubarao>
References: <468F3FDA28AA87429AD807992E22D07E014CEF36@orsmsx408>
	 <1093542930.1027.124.camel@jzny.localdomain>
	 <1093550644.20769.130.camel@tubarao>  <412E478A.2000806@pobox.com>
Reply-To: tharbaugh@lnxi.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <412E478A.2000806@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-08-26 at 16:26 -0400, Jeff Garzik wrote:
> Thayne Harbaugh wrote:
> > On Thu, 2004-08-26 at 13:55 -0400, jamal wrote:
> > 
> >>Ganesh,
> >>
> >>Can you please make this feature off by default and perhaps
> >>accesible via ethtool for peopel who want to turn it on.
> >>I just wasted a few hours and was bitten by this performance-wise.
> >>Please consider disabling it.
> > 
> > 
> > This is a *horrible* problem.  Even though it's fixable by passing a
> > module parameter, the default bites those that *know* about it.  We have
> > had customers bitten by this and customers that have insisted in
> > swapping all the NICs in a cluster to Broadcom TG3 NICs.
> > 
> > It's a black eye for Intel and a loss of business - that's the opinion
> > of our customers.
> 
> 
> If it's so bad we should disable it by default, either via the module 
> parameter or via a kernel CONFIG_xxx option.

Yes, it is so bad.  The dynamic interrupt setting should be deprecated
by the use of NAPI.

This is a simple way to disable it, yet still keep the code so that
someone can enable it if they really wanted it.  I, however, would just
as soon see all of the DITR code ripped out.

There are other ways that might be better for dealing with it, yet still
keeping the DITR code viable.

--- drivers/net/e1000/e1000_param.c.broken_ditr 2004-08-26 15:40:34.436456736 -0600
+++ drivers/net/e1000/e1000_param.c     2004-08-26 15:49:07.186506880 -0600
@@ -212,7 +212,7 @@
 #define MAX_TXABSDELAY            0xFFFF
 #define MIN_TXABSDELAY                 0
  
-#define DEFAULT_ITR                    1
+#define DEFAULT_ITR                 8000
 #define MAX_ITR                   100000
 #define MIN_ITR                      100
  
