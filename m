From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 3/3] r8169: clean up
Date: Tue, 2 Nov 2004 13:47:39 -0600
Message-ID: <200411021347.39047.jdmason@us.ibm.com>
References: <200411021203.25100.jdmason@us.ibm.com> <20041102192746.GB24860@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041102192746.GB24860@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 02 November 2004 01:27 pm, Francois Romieu wrote:
> Jon Mason <jdmason@us.ibm.com> :
> > Removal of some magic numbers, unnecessary double not, and addition of
> > "link down" notification.
> >
> > Signed-off-by: Jon Mason <jdmason@us.ibm.com>
> >
> > --- r8169.c     2004-11-02 10:37:31.035203120 -0600
> > +++ r8169.c.latest      2004-11-02 10:44:01.367863536 -0600
>
> [...]
>
> > @@ -773,7 +775,7 @@ static void rtl8169_gset_tbi(struct net_
> >
> >         status = RTL_R32(TBICSR);
> >         cmd->advertising = (status & TBINwEnable) ?  ADVERTISED_Autoneg :
> > 0; -       cmd->autoneg = !!(status & TBINwEnable);
> > +       cmd->autoneg = status & TBINwEnable;
> >
> >         cmd->speed = SPEED_1000;
> >         cmd->duplex = DUPLEX_FULL; /* Always set */
>
> drivers/net/*.c use 0/1 or AUTONEG_{EN/DIS}ABLE.

Silly question, does "!!" not execute a bitwise not twice?  If not, then 
please forgive my ignorance.

If so, then it is unnecessary.  But if you want something prettier, how about:

 cmd->autoneg = (status & TBINwEnable) ? AUTONEG_ENABLE : AUTONEG_DISABLE;

-- 
Jon Mason
jdmason@us.ibm.com
