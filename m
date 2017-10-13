From: Alan Cox <gnomes-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Fri, 13 Oct 2017 14:43:11 +0100
Message-ID: <20171013144311.45856ba2@alans-desktop>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Carlos O'Donell" <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
        Al Viro <viro-RmSDqhL/yNOmg8Ev75riOw@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171012141359.saqdtnodwmbz33b2-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Oct 2017 10:14:00 -0400
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> Containers are a userspace concept.  The kernel knows nothing of them.
> 
> The Linux audit system needs a way to be able to track the container
> provenance of events and actions.  Audit needs the kernel's help to do
> this.
> 
> Since the concept of a container is entirely a userspace concept, a
> registration from the userspace container orchestration system initiates
> this.  This will define a point in time and a set of resources
> associated with a particular container with an audit container ID.

I don't think this has anything to do with containers directly. If i
read it right you need a subtree of stuff to be asigned a (possibly
irrevocable) magic identifier that you can use for other purposes.

Traditional Unix in the more 'secure' space had that decades ago in the
form of luid. At login time you did a setluid() and that set an
irrevocable tag onthe session which was (traditionally) the uid of the
login process so that audit and other related tools always knew how to
tie the process back to the login session.

That doesn't quite work as of itself (if you login you'd get luid set and
not be able to change it for the container), but it seems something
similarly trivial like a "setauditid(void)" would do the trick providing
the kernel picked the UUID randomly [otherwise I can copy another known
UUID to confuse or hide].

As you say a container is a userspace concept. So IMHO any audit
interface should be about auditing and what needs tracking, not about
containers. If the container management tool wants to set a suitable tag
then let it. If not then it doesn't.

Then it's a simple as checking CAP_AUDIT_WRITE to see if you are allowed
to setauditit(), generating a random uuid and a matching getauditid() to
copy it back.

Alan
