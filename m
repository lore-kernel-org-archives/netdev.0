From: James Morris <jmorris@redhat.com>
Subject: Re: Asynchronous crypto layer.
Date: Tue, 14 Dec 2004 02:23:55 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0412140159470.30724-100000@thoron.boston.redhat.com>
References: <20041102191235.609efde6@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>, Michal Ludvig <michal@logix.cz>,
        <netdev@oss.sgi.com>, <cryptoapi@lists.logix.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20041102191235.609efde6@zanzibar.2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Nov 2004, Evgeniy Polyakov wrote:

Some feedback:

+#define session_completed(s)   (s->ci.flags & SESSION_COMPLETED)
+#define complete_session(s)    do {s->ci.flags |= SESSION_COMPLETED;} while(0)
+#define uncomplete_session(s)  do {s->ci.flags &= ~SESSION_COMPLETED;} while (0)
etc.

Please use static inlines for all of these things.
Are these supposed to be exported to userspace?  Why?


+struct crypto_conn_data
+{
+       char                    name[SCACHE_NAMELEN];
+       __u16                   cmd;

Again, exporting to userspace?


+       list_for_each_entry_safe(__dev, n, &cdev_list, cdev_entry)
+       {
+               if (compare_device(__dev, dev))
+               {

Incorrect coding style (and many more).

As mentioned before, pluggable load balacers are not needed now, and 
complicate the code.


- James
-- 
James Morris
<jmorris@redhat.com>
