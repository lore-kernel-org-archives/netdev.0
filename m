From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [5/5] 2.6.22-rc2: known regressions
Date: Sat, 19 May 2007 21:57:37 -0700
Message-ID: <20070519215737.5a98a070@freepuppy>
References: <464F6DC9.80805@googlemail.com> <464F74E9.8080102@googlemail.com>
	<20070519.153829.112852602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, bcollins@ubuntu.com,
	michal.k.k.piotrowski@gmail.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	doug.chapman@hp.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	akpm@linux-foundation.org, yoshfuji@linux-ipv6.org,
	torvalds@linux-foundation.org, cramerj@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070519.153829.112852602.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, 19 May 2007 15:38:29 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> Date: Sun, 20 May 2007 00:06:33 +0200
> 
> > Subject    : OOPS triggered by ip(8) deconfiguring a network interface
> > References : http://bugzilla.kernel.org/show_bug.cgi?id=8491
> > Submitter  : Ben Collins <bcollins@ubuntu.com>
> > Status     : Unknown
> 
> Might be fixed by:
> 
> 	http://marc.info/?l=linux-netdev&m=117915849224816&w=2
> 
> I'll merge that patch in and we'll see what happens.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Looks more like the IPV6 SNMP6 OOPS, I saw and fixed with:

commit 5632c5152aa621885d87ea0b8fdd5a6bb9f69c6f
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Sat Apr 28 21:16:39 2007 -0700

    [IPV6]: Track device renames in snmp6.
    
    When network device's are renamed, the IPV6 snmp6 code
    gets confused. It doesn't track name changes so it will OOPS
    when network device's are removed.
    
    The fix is trivial, just unregister/re-register in notify handler.
    
    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>


-- 
Stephen Hemminger <shemminger@linux-foundation.org>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
