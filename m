From: Peter Dolding <oiaohm@gmail.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal
	firewalls"
Date: Wed, 21 Jan 2009 18:15:52 +1000
Message-ID: <e7d8f83e0901210015h5f0f7489u282a50911bf7a988@mail.gmail.com>
References: <57962.77.61.51.106.1232522729.squirrel@webmail.xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	Samir Bellabes <sam@synack.fr>, imipak@yahoo.com,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Stephan Peijnik <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: rmeijer@xs4all.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.180]:2902 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754943AbZAUIPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 03:15:54 -0500
In-Reply-To: <57962.77.61.51.106.1232522729.squirrel@webmail.xs4all.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2009 at 5:25 PM, Rob Meijer <capibara@xs4all.nl> wrote:
> On Wed, January 21, 2009 02:18, Casey Schaufler wrote:
>>
>>> we don't need this at all, as we are in process context, syscall can
>>> sleep.
>>> Trust me, it's strange to have it's web browser freezing waiting for a
>>> timeout if the userspace part doesn't reply, but if it's replying, it's
>>> transparent.
>>
>> I hate to be the one to say this, but it looks to me as if the
>> easiest way to solve the problems that you have outlined would
>> be to create a new LSM based on SELinux with two important
>> changes. The first would be to have a separate policy for each
>> user (or process tree) and the second would be to make the policy
>> specification discretionary. SELinux has all the mechanism you're
>> talking about, but you want the policy being enforced to reflect
>> a set of "personal firewall" rules rather than "domain type" rules.
>>  From the lobby at LCA in Hobart these rule sets are pretty hard to
>> tell apart. And let's not have the "SELinux isn't designed to do
>> that" row. Of course it isn't. Nonetheless, the personal firewall
>> sure sounds a lot like SELinux if you ignore the MAC/DAC difference.
>
> I think this is a perfect example of where using MAC 'and' DAC or rather
> centrally 'and' user managed profiles would be very fruitful. If you can
> create a purely permissive centrally managed per user profile, in fact
> delegating a permission set and allow each user to decompose and
> discretionary delegate parts of this profile to programs run by this same
> user, but with MAC restrictions when delegating to a process run by a
> different user, you would IMHO have a very powerful combination of MAC and
> DAC.
>
> I'm not sure however a label based MAC system would be best suited for
> combining MAC and DAC in such a way.
>
>
>
I really don't see the need for special here other than improving iptables.

LSM module is over kill.  This leads to double processing of packet requests.

netfilter already can operate as either MAC or DAC all depending on
the rules passed into it and the outside LSM applied.  selinux and
other lsm's can stop applications from changing the netfilter.  So
basic filtering of what can be changed in iptables basically turns
iptables from a DAC to a MAC.  Advantage added no more layors for
network packets to go though.

Only cost for outgoing really is changing the rules.  Once rules are
set cost compare to normal disappears.

Yes there will be a cost on incoming since application level incoming
filtering is not done at the moment.  There is a major problem here
for tuxguardian idea of being at the application API interface how in
heck are you going to block something before it has to travel all the
way threw the net-filter stack.  [network
card]-[netfilter]-[applicaiton]  Idea makes it [network
card]-[netfilter]-[application filter]-[application]  Really a bad
outcome.   If user say on X port they don't want traffic from X IP but
they want to let other IP's tuxguardian still has to netfilter so its
stoped soon enough.   No point processing items you are just dropping.

Netfilter can already reject or approve out going packets from
applications on the base of user id process id and so on.  This is
before packets enter the Netfilter processing stack.   Cost of looking
up if applicaiton is approved or not appoved is out weight be the cost
of rejected packets going trough netfilter.

Sorry netfilter is already sorting out how sockets can be used.   What
you are basically talking about is two layors doing exactly the same
thing.   Half of what tuxguardian does can be done in a iptables
module.  Ie filtering out going traffic based on application.

Please explain why expanding netfilter is not a option.   Expanding
netfilter avoids conflicts with LSM's.

Filtering traffic coming into applications is missing.  I am also
sorry tuxguardian over looks something using i7filter would allow
applications to share the same port number or block invalid type
packets being sent to an application.

True solid home firewall solution really should be able to use
i7filtering where needed.   Same with multi user-support.

The idea that personal firewall does not need to filter packets is
foolish.   Also the idea that machines that are always single user
exist is also foolish.  More and more Linux distributions are
supporting user switching.  Linux is completely designed as an multi
user OS.   So design need to take that into account.

Peter Dolding
