From: Stephen Smalley <sds@epoch.ncsc.mil>
Subject: Re: [RFC] SO_PEERSEC - security credentials for Unix stream sockets
Date: Tue, 16 Dec 2003 08:47:31 -0500
Sender: linux-security-module-bounces@wirex.com
Message-ID: <1071582451.32407.12.camel@moss-spartans.epoch.ncsc.mil>
References: <Xine.LNX.4.44.0312160816350.16300-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
	Chris Wright <chrisw@osdl.org>,
	lsm <linux-security-module@wirex.com>, netdev@oss.sgi.com,
	kuznet@ms2.inr.ac.ru
Return-path: <linux-security-module-bounces@wirex.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0312160816350.16300-100000@thoron.boston.redhat.com>
List-Unsubscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=unsubscribe>
List-Archive: <http://mail.immunix.com/pipermail/linux-security-module>
List-Post: <mailto:linux-security-module@mail.wirex.com>
List-Help: <mailto:linux-security-module-request@mail.wirex.com?subject=help>
List-Subscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=subscribe>
Errors-To: linux-security-module-bounces@wirex.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-12-16 at 08:19, James Morris wrote:
> It's not reliable: the required buffer size could change between calls.  
> Do you know of any examples of syscalls which do this?

getxattr(2).  From the man page:

       An empty buffer of size zero can be passed into these calls  to  return
       the  current size of the named extended attribute, which can be used to
       estimate the size of a buffer which is sufficiently large to  hold  the
       value associated with the extended attribute.
                                                                                
       The  interface  is  designed to allow guessing of initial buffer sizes,
       and to enlarge buffers when the return value indicates that the  buffer
       provided was too small.

The SELinux getfilecon(3) function (libselinux/src/getfilecon.c) uses
getxattr(2) in this manner.

-- 
Stephen Smalley <sds@epoch.ncsc.mil>
National Security Agency
