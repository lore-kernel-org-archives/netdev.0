From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] locking changes for lec.c
Date: Fri, 14 Jan 2005 20:33:51 -0800
Message-ID: <20050114203351.14effe19.davem@davemloft.net>
References: <20050114135612.0edc180d.davem@davemloft.net>
	<200501150232.j0F2Wovr010942@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200501150232.j0F2Wovr010942@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 14 Jan 2005 21:32:51 -0500
"chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil> wrote:

> In message <20050114135612.0edc180d.davem@davemloft.net>,"David S. Miller" writes:
> >Can HW interrupt paths ever call into this ARP stuff?
> >If not, probably should just use BH disabled locking
> >instead of the heavy handed IRQ disabling locks.
> 
> yes, lec_push() could be run in hw interrupt context from one of of the
> atm drivers recv path.  in fact, this is the path where i "noticed" the
> race condition.

Ok.  As a future thought, if you make the ATM driver receive path
NAPI in style or run always from softint processing, you can
undo all the IRQ based locking.
