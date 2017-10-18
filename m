From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Thu, 19 Oct 2017 10:46:18 +1100
Message-ID: <49752b6f-8a77-d1e5-8acb-5a1eed0a992c@suse.de>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
	<75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
	<20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
	<2319693.5l3M4ZINGd@x2> <1508243469.6230.24.camel@redhat.com>
	<a07968f6-fef1-f49d-01f1-6c660c0ada20@schaufler-ca.com>
	<1508254120.6230.34.camel@redhat.com>
	<1508255091.3129.27.camel@HansenPartnership.com>
	<CAHC9VhRV9m6-APj3ofMQc22rL-WUoDzB8-urUxryszjCHHHLTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
	James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAHC9VhRV9m6-APj3ofMQc22rL-WUoDzB8-urUxryszjCHHHLTg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

>> The security implications are that anything that can change the label
>> could also hide itself and its doings from the audit system and thus
>> would be used as a means to evade detection.  I actually think this
>> means the label should be write once (once you've set it, you can't
>> change it) ...
> 
> Richard and I have talked about a write once approach, but the
> thinking was that you may want to allow a nested container
> orchestrator (Why? I don't know, but people always want to do the
> craziest things.) and a write-once policy makes that impossible.  If
> we punt on the nested orchestrator, I believe we can seriously think
> about a write-once policy to simplify things.

Nested containers are a very widely used use-case (see LXC system 
containers, inside of which people run other container runtimes). So I 
would definitely consider it something that "needs to be supported in 
some way". While the LXC guys might be a *tad* crazy, the use-case isn't. :P

>> ... and orchestration systems should begin as unlabelled
>> processes allowing them to do arbitrary forks.
> 
> My current thinking is that the default state is to start unlabeled (I
> just vomited a little into my SELinux hat); in other words
> init/systemd/PID-1 in the host system starts with an "unset" audit
> container ID.  This not only helps define the host system (anything
> that has an unset audit container ID) but provides a blank slate for
> the orchestrator(s).
> 
>> For nested containers, I actually think the label should be
>> hierarchical, so you can add a label for the new nested container but
>> it still also contains its parents label as well.
> 
> I haven't made up my mind on this completely just yet, but I'm
> currently of the mindset that supporting multiple audit container IDs
> on a given process is not a good idea.

As long as creating a new "container" (that is, changing a process's 
"audit container ID") is an audit event then I think that having a 
hierarchy be explicit is not necessary (userspace audit can figure out 
the hierarchy quite easily -- but also there are cases where thinking of 
it as being hierarchical isn't necessarily correct).

-- 
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
