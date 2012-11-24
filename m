From: Libo Chen <chenlibo.3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC 3/5] printk: modify printk interface for
	syslog_namespace
Date: Sat, 24 Nov 2012 19:22:03 +0800
Message-ID: <50B0ADDB.4000303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

On 2012/11/22 1:49, Serge E. Hallyn wrote:

> I notice that you haven't made any changes to the struct cont.  I
> suspect this means that to-be-continued msgs from one ns can be
> erroneously mixed with another ns.
>
Yes, I confirmed this problem. There will be erroneously mixed with another ns.
Thank you very much.

> You said you don't mind putting the syslogns into the userns.  If
> there's no reason not to do that, then we should do so as it will
> remove a bunch of code (plus the use of a new CLONE flag) from your
> patch, and the new syslog(NEW_NS) command from mine.
>
I agree with you, both are removable.

> Now IMO the ideal place for syslog_ns would be in the devices ns,
> but that does not yet exist, and may never.  The bonus to that would
> be that the consoles sort of belong there.  I avoid this by not
> having consoles in child syslog namespaces.  You put the console in
> the ns.  I haven't looked closely enough to see if what you do is
> ok (will do so soon).
>
> WOuld you mind looking through my patch to see if it suffices for
> your needs?  Where it does not, patches would be greatly appreciated
> if simple enough.

follow your patch, I can see inject message by "dmesg call" in container, is right?
I am worry that I debug  or see messages from serial ports console in some embedded system,
since console belongs to init_syslog,  so the message in container can`t be printed. 

> Note I'm not at all wedded to my patchset.  I'm happy to go with
> something else entirely.  My set was just a proof of concept.
>
>
