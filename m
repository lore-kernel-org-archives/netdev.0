From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RFC for sysfs management of TIPC
Date: Thu, 9 Feb 2012 14:14:12 -0500
Message-ID: <0434463FDA60A94FA978ACA44617682DF7A43C76D1@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Xue, Ying \(Ying.Xue@windriver.com\)" <Ying.Xue@windriver.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>, "Stephens, Allan
	\(allan.stephens@windriver.com\)" <allan.stephens@windriver.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

TIPC currently provides a netlink interface towards a user space 
program (tipc-config), which is used to turn the different knobs
and levers of TIPC. 
This program is provided by some distributions package systems,
and is also downloadable from SourceForge.

Now, we are considering the option of making the configuration 
available as a structured tree in sysfs.
Before we invest any more time in this, we'd like to get feedback on 
whether people think this is a worthwhile change to undertake.

What follows below is an initial draft of what we think the user 
interface would look like.  If you have any feedback on whether you 
think this feature is a good idea, or if you think it isn't worth pursuing 
any further, we would appreciate your input.

/* 
  * The top level sysfs directory /tipc holds all global configuration.
  * The address file shall accept a string representation of a TIPC
  * address. The 'ports' and 'nametable' are read-only files that can
  * dump a list of active TIPC ports and published names.
  * The rest are integer attributes.
  */
/sys/.../tipc/
address maxports maxpub maxsubscr netid ports nametable


/* 
  * Each registered media type will have a directory under /media .
  * It should be possible to set default (integer) 
  * priority/windowsize/tolerance that will apply for all bearers 
  *enabled on a given media type 
  */
/sys/.../tipc/media/
priority tolerance windowsize


/* 
  * The /bearer directory have two persistent files to enable/disable
  * bearers.
  * By writing the bearer string to the add/delete file it will
  * subsequently be enabled or disabled. The bearer string is in the
  * format <media>:<interface name>
  */
/sys/.../tipc/bearer/
add delete

/* 
  * Each enabled bearer are represented by a directory under /bearer.
  * It should be possible to set the default (integer)
  * priority/windowsize/tolerance that will apply for all links enabled
  * over a given bearer.
  */
/sys/.../tipc/bearer/eth:eth1/
priority tolerance windowsize


/* 
  *All established links are listed as a separate directory under /link 
  */ 
/sys/.../tipc/link/

/* 
  * Each link have a set of attribute files, each containing 1 unique
  * integer value.
  * The statistics file holds per-link statistics that can be reset
  * with the 'reset' command
  */
/sys/.../tipc/link/1.1.1:eth1-1.1.2:eth1/
priority tolerance windowsize statistics

Regards
Jon Maloy
Erik Hugne

------------------------------------------------------------------------------
Virtualization & Cloud Management Using Capacity Planning
Cloud computing makes use of virtualization - but cloud computing 
also focuses on allowing computing to be delivered as a service.
http://www.accelacomm.com/jaw/sfnl/114/51521223/
