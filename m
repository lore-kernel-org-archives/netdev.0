From: Edgar Toernig <froese@gmx.de>
Subject: Re: [PATCH] Consolidate multiple implementations of jiffies-msecs
 conversions.
Date: Fri, 26 Mar 2004 01:44:03 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040326014403.39388cb8.froese@gmx.de>
References: <Pine.LNX.4.58.0403251142110.3037@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jgarzik@pobox.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0403251142110.3037@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
> 
> The following patch to 2.6.5-rc2 consolidates 6 different implementations
> of msecs to jiffies and 3 different implementation of jiffies to msecs.
> All of them now use the generic msecs_to_jiffies() and jiffies_to_msecs()
> that are added to include/linux/time.h
>[...]
> -#define MSECS(ms)  (((ms)*HZ/1000)+1)
> -return (((ms)*HZ+999)/1000);
> +return (msecs / 1000) * HZ + (msecs % 1000) * HZ / 1000;

Did you check that all users of the new version will work correctly
with your rounding?  Explicit round-up of delays is often required,
especially when talking to hardware...

Ciao, ET.
