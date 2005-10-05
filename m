From: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2005@gmx.net>
Subject: Re: ip address delete bug?
Date: Wed, 05 Oct 2005 17:32:34 +0200
Message-ID: <4343F212.6020606@gmx.net>
References: <200593200127124@mail.routehat.org> <4342D3F9.80705@gmx.net>	
	<Pine.NEB.4.62.0510042118190.24353@ukato.freeshell.org>	
	<4343090B.5010803@gmx.net>	
	<Pine.NEB.4.62.0510042307290.6475@ukato.freeshell.org>
	<1128474946.6224.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, netdev@vger.kernel.org
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: hadi@cyberus.ca
In-Reply-To: <1128474946.6224.8.camel@localhost.localdomain>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2005-04-10 at 23:08 +0000, Alexey Toptygin wrote:
> 
>>On Wed, 5 Oct 2005, Carl-Daniel Hailfinger wrote:
> 
> [..]
> 
>>>Normally, I would add the new IP to eth0, start another ssh to the new IP, 
>>>log out from the session to the old IP, remove the old IP from eth0 and be 
>>>done. If I want the server to be reachable under both IPs during a transition 
>>>period, I can delay deletion of the old IP until later.
>>
>>Then I guess the question is: does anything in common use depend on the 
>>old behavior?
> 
> There's a new feature in newer kernels which allows for an alias to be
> upgraded to become primary when you delete the primary. You need to
> configure the sysctl otherwise it defaults to purging all the
> secondaries when you delete the primary.

Thanks for that feature! Just looked at
/proc/sys/net/ipv4/conf/*/promote_secondaries
and it is the feature I was looking for. Merged in 2.6.12, if anyone 
reads this in a mail archive and wonders whether he has to upgrade.


This leads to another question: Can I manually promote a secondary 
address to become primary without deleting the primary? This would help 
me to use the new address by default during the transition period.


> What it sounds like is you need to have ssh run over SCTP instead of TCP
> to allow multi-homing. 

Maybe, but I did not find any current openssh version with sctp support. 
And with promote_secondaries, my original problem is solved perfectly.


Regards,
Carl-Daniel
-- 
http://www.hailfinger.org/
