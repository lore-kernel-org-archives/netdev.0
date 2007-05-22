From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: Don't enable polling in open()
 (was: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1)
Date: Mon, 21 May 2007 17:04:53 -0700
Message-ID: <465233A5.4060102@intel.com>
References: <20070521215134.14885.84952.stgit@localhost.localdomain>
	<46522E6F.9060600@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, e1000-devel@lists.sourceforge.net,
	Greg KH <greg@kroah.com>, netdev@vger.kernel.org, davej@redhat.com,
	stable@kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46522E6F.9060600@garzik.org>
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

Jeff Garzik wrote:
> Auke Kok wrote:
>> Herbert Xu wrote:
>> "netif_poll_enable can only be called if you've previously called
>> netif_poll_disable.  Otherwise a poll might already be in action
>> and you may get a crash like this."
>>
>> Removing the call to netif_poll_enable in e1000_open should fix this issue,
>> the only other call to netif_poll_enable is in e1000_up() which is only
>> reached after a device reset or resume.
>>
>> Bugzilla: http://bugzilla.kernel.org/show_bug.cgi?id=8455
>> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=240339
>>
>> Tested by Doug Chapman <doug.chapman@hp.com>
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
>> ---
>>
>>  drivers/net/e1000/e1000_main.c |    4 ----
>>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> applied, though as a poster (DaveJ?) noted, I'm not sure it completely 
> fixes the bug

It fixes the HP IA64 issue reported by Doug Chapman, but indeed does not even 
apply to the FC bugzilla. I was mistaken due to the fact that I sent the code 
that introduced the bug a while ago, but it's not in 2.6.21 (it was in the 
e1000-fixes tree you had and merged after 2.6.21).

So, this patch doesn't apply for -stable.


Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
