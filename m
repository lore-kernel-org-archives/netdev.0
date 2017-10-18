From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Tue, 17 Oct 2017 20:23:01 -0400
Message-ID: <16761682.puRDTGPHq7@x2>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
	<1982291.vr6V9CPzqu@x2>
	<1508263063.3129.35.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
	Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>,
	Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
To: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1508263063.3129.35.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
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

On Tuesday, October 17, 2017 1:57:43 PM EDT James Bottomley wrote:
> > > > The idea is that processes spawned into a container would be
> > > > labelled by the container orchestration system.  It's unclear
> > > > what should happen to processes using nsenter after the fact, but
> > > > policy for that should be up to the orchestration system.
> > > 
> > > I'm fine with that. The user space policy can be anything y'all
> > > like.
> > 
> > I think there should be a login event.
> 
> I thought you wanted this for containers?  Container creation doesn't
> have login events.  In an unprivileged orchestration system it may be
> hard to synthetically manufacture them.

I realize this. This work is very similar to problems we've solved 12 years 
ago. We'll figure out what the right name is for it down the road. But the 
concept is the same. If something enters a container, we need to know about 
it. It needs to get tagged and be associated with the container. The way this 
was solved for the loginuid problem was to add a session identifier so that 
new logins of the same loginuid can coexist and we can trace actions back to a 
specific login. I'd think we can apply lessons learned from a while back to 
make container identification act similarly.

-Steve
