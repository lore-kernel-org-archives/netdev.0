From: "Amit Shah" <shahamit@gmail.com>
Subject: Re: [Bugme-new] [Bug 10748] New: dhclient fails to run; capabilities error
Date: Tue, 20 May 2008 19:18:35 +0530
Message-ID: <877aabc40805200648s3045b123p893888363eb84ad@mail.gmail.com>
References: <bug-10748-10286@http.bugzilla.kernel.org/>
	 <20080519112835.67ff4133.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	"Andrew Morgan" <morgan@kernel.org>,
	"Stephen Smalley" <sds@tycho.nsa.gov>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:17271 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbYETNsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 09:48:36 -0400
Received: by rv-out-0506.google.com with SMTP id l9so2025896rvb.1
        for <netdev@vger.kernel.org>; Tue, 20 May 2008 06:48:35 -0700 (PDT)
In-Reply-To: <20080519112835.67ff4133.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2008 at 11:58 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> whoa, weird.  Could you please run `sudo strace -f dhclient eth2' and send us
> the last page or so of output?
>

Sorry, I should've done that earlier.

9311  open("/var/lib/dhcp3/dhclient.leases", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 4
9311  chown("/var/lib/dhcp3/dhclient.leases", 100, 4294967295) = 0
9311  fstat(4, {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
9311  mmap(NULL, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fc511e8f000
9311  write(4, "lease {\n  interface \"eth0\";\n  fi"..., 531) = 531
9311  open("/var/run/dhclient.pid", O_WRONLY|O_CREAT|O_TRUNC, 0644) = 5
9311  fcntl(5, F_GETFL)                 = 0x8001 (flags O_WRONLY|O_LARGEFILE)
9311  fstat(5, {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
9311  mmap(NULL, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fc511e8e000
9311  lseek(5, 0, SEEK_CUR)             = 0
9311  open("/etc/passwd", O_RDONLY|0x80000 /* O_??? */) = 6
9311  lseek(6, 0, SEEK_CUR)             = 0
9311  fstat(6, {st_mode=S_IFREG|0644, st_size=1558, ...}) = 0
9311  mmap(NULL, 1558, PROT_READ, MAP_SHARED, 6, 0) = 0x7fc511e8d000
9311  lseek(6, 1558, SEEK_SET)          = 1558
9311  munmap(0x7fc511e8d000, 1558)      = 0
9311  close(6)                          = 0
9311  socket(PF_FILE, SOCK_STREAM, 0)   = 6
9311  fcntl(6, F_SETFL, O_RDWR|O_NONBLOCK) = 0
9311  connect(6, {sa_family=AF_FILE, path="/var/run/nscd/socket"},
110) = -1 ENOENT (No such file or directory)
9311  close(6)                          = 0
9311  socket(PF_FILE, SOCK_STREAM, 0)   = 6
9311  fcntl(6, F_SETFL, O_RDWR|O_NONBLOCK) = 0
9311  connect(6, {sa_family=AF_FILE, path="/var/run/nscd/socket"},
110) = -1 ENOENT (No such file or directory)
9311  close(6)                          = 0
9311  open("/etc/group", O_RDONLY|0x80000 /* O_??? */) = 6
9311  lseek(6, 0, SEEK_CUR)             = 0
9311  fstat(6, {st_mode=S_IFREG|0644, st_size=923, ...}) = 0
9311  mmap(NULL, 923, PROT_READ, MAP_SHARED, 6, 0) = 0x7fc511e8d000
9311  lseek(6, 923, SEEK_SET)           = 923
9311  munmap(0x7fc511e8d000, 923)       = 0
9311  close(6)                          = 0
9311  prctl(0x8, 0x1, 0, 0, 0)          = -1 EINVAL (Invalid argument)
9311  dup(2)                            = 6
9311  fcntl(6, F_GETFL)                 = 0x8002 (flags O_RDWR|O_LARGEFILE)
9311  fstat(6, {st_mode=S_IFCHR|0600, st_rdev=makedev(136, 2), ...}) = 0
9311  mmap(NULL, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fc511e8d000
9311  lseek(6, 0, SEEK_CUR)             = -1 ESPIPE (Illegal seek)
9311  write(6, "drop_privileges: could not keep "..., 63) = 63
9311  close(6)                          = 0
9311  munmap(0x7fc511e8d000, 4096)      = 0
9311  exit_group(-1)                    = ?

-- 
Amit Shah
http://www.amitshah.net/
