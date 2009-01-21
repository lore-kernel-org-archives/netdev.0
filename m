From: Samir Bellabes <sam@synack.fr>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Wed, 21 Jan 2009 04:14:29 +0100
Message-ID: <m2wscp1hbe.fsf@ssh.synack.fr>
References: <317242.47729.qm@web31508.mail.mud.yahoo.com>
	<m28wp532dz.fsf@ssh.synack.fr> <497677CC.105@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: imipak@yahoo.com,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Stephan Peijnik <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497677CC.105@schaufler-ca.com> (Casey Schaufler's message of
	"Tue, 20 Jan 2009 17:18:04 -0800")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Casey Schaufler <casey@schaufler-ca.com> writes:

> I hate to be the one to say this, but it looks to me as if the
> easiest way to solve the problems that you have outlined would
> be to create a new LSM based on SELinux with two important
> changes. 

Hi Casey,
I'm very interesting by this thought. because I don't have enough
background on security models.

> The first would be to have a separate policy for each
> user (or process tree) and the second would be to make the policy
> specification discretionary.

I got this, but I don't see what it's implying exactly.

> SELinux has all the mechanism you're
> talking about, but you want the policy being enforced to reflect
> a set of "personal firewall" rules rather than "domain type" rules.

ok, I understand the link with the domain type, and I agree.

> From the lobby at LCA in Hobart these rule sets are pretty hard to
> tell apart. 

By my experience on it, I fully agree.
At first, I jumped on how to build this rule sets, I just totally
failed. Specially for dropping rule, and worse: how to order rules.

Then we also need to join sets : (fixing a specific user)

     deny socket() for application X +
   + deny accept() for application X +
   + deny listen() for application X +
   + deny bind() for application X + .. (all syscalls)

 == deny all syscall for 'application X'

So the case of having all the denying rules, minus one, and the user
adding the missing rule, is not just adding the rule, but it's to 'add'
all of them to get only one.
and then we need to put priority/order on keys : filtering by uid first
? application first ?

I don't know how to do that. what I known for sure is that I don't want
to spend the next 20 years trying to solve this problem. 
that's why I focused on the better way to pass the informations to
userspace, at let someone who actually may implements a way to managed
this rules sets, with the simplest design to interact with the
kernel/API mechanism.

> And let's not have the "SELinux isn't designed to do
> that" row. Of course it isn't. Nonetheless, the personal firewall
> sure sounds a lot like SELinux if you ignore the MAC/DAC difference.

maybe, but for sure what SELinux is not doing is this :

1. I'm editing the sshd_config file to put the server to listen on the
   port 2222.
2. starting server
3. SELinux is not aware of that, it's not working
4. I have to put another conf inside SELinux to allow it (but actually
   didn't I already do it in 1 ?)

then it will work.

with the idea of userspace interaction (asking user, check a database)
1. I'm editing the sshd_config file to put the server to listen on the
   port 2222.
2. staring server -> listen() -> catch it in userspace, ask (X user,
   remote admin, automatic mecanism/database

only one config, tool is focusing on providing security : is this
allowed or not ? that's all.

And snet API can be used by others programs. As actually I'm developping
a opengl tool that is representing network informations, in real
time. This can't be done with SELinux.
But the main goal to achieve, is to make all boxes running in a LAN
aware of themselves and interact also with the main firewall, according
to the admin decisions. 

sam
