From: jamal <hadi@cyberus.ca>
Subject: Re: [UPDATED PATCH] Re: Re: [Patch 7/7] Generic netlink
	interface (delay	accounting)
Date: Sat, 11 Mar 2006 08:30:49 -0500
Message-ID: <1142083849.5184.69.camel@jzny2>
References: <1141026996.5785.38.camel@elinux04.optonline.net>
	 <1141029060.5785.77.camel@elinux04.optonline.net>
	 <1141045194.5363.12.camel@localhost.localdomain>
	 <4403608E.1050304@watson.ibm.com>
	 <1141652556.5185.64.camel@localhost.localdomain>
	 <440C6AAA.9030301@watson.ibm.com>
	 <1141742282.5171.55.camel@localhost.localdomain>
	 <440F52FF.30908@watson.ibm.com> <20060309143759.GA4653@in.ibm.com>
	 <1142002433.5298.42.camel@jzny2>  <20060310163927.GA6537@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Shailabh Nagar <nagar@watson.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	lse-tech@lists.sourceforge.net
Return-path: <lse-tech-admin@lists.sourceforge.net>
To: balbir@in.ibm.com
In-Reply-To: <20060310163927.GA6537@in.ibm.com>
Sender: lse-tech-admin@lists.sourceforge.net
Errors-To: lse-tech-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/lse-tech>,
	<mailto:lse-tech-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:lse-tech@lists.sourceforge.net>
List-Help: <mailto:lse-tech-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/lse-tech>,
	<mailto:lse-tech-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=lse-tech>
List-Id: netdev.vger.kernel.org

On Fri, 2006-10-03 at 22:09 +0530, Balbir Singh wrote:
> On Fri, Mar 10, 2006 at 09:53:53AM -0500, jamal wrote: 

> > On kernel->user (in the case of response to #a or async notifiation as
> > in #b) you really dont need to specify the TG/PID since they appear in
> > the STATS etc.
> 
> I see your point now. I am looking at other users of netlink like
> rtnetlink and I see the classical usage.
> 
> We can implement TLV's in our code, but for the most part the data we exchange
> between the user <-> kernel has all the TLV's listed in the enum above.
>
> The major differnece is the type (pid/tgid). Hence we created a structure
> (taskstats) instead of using TLV's.

Something to remember:

1) TLVs are essentially giving you the flexibility to send optionally
appearing elements. It is up to the receiver (in the kernel or user
space) to check for the presence of mandatory elements or execute things
depending on the presence of certain TLVs. Example in your case:
if the tgid TLV appears then the user is requesting for that TLV
if the pid appears then they are requesting for that
if both appear then it is the && of the two.
You should always ignore TLVs you dont understand - to allow for forward
compatibility.

2)  The "T" part is essentially also encoding (semantically) what size
the value is; the "L" part is useful for validation. So the receiver
will always know what the size of the TLV is by definition and uses the
L to make sure it is the right size. Reject what is of the wrong size.

cheers,
jamal



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
