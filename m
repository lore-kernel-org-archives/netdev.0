From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: network regression: cannot rename netdev twice
Date: Tue, 31 Jan 2012 06:18:00 -0800
Message-ID: <m18vko6jmv.fsf@fess.ebiederm.org>
References: <4F27120A.4040106@suse.cz>
	<CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com>
	<4F27C54F.1010107@suse.cz>
	<CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
	<4F27C9D4.3040105@suse.cz>
	<CAPXgP12pj6esZVmN-PYTVgJ+_MaAfmpa9hKoKKQZ+Y=Y-Kb4eA@mail.gmail.com>
	<4F27CDBC.5020201@suse.cz>
	<CAPXgP1371fgmaP3ecxsDJ2BmJrOS6kUP95G1BHe6deBPk5FVCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby@suse.cz>, Greg KH <greg@kroah.com>,
	LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPXgP1371fgmaP3ecxsDJ2BmJrOS6kUP95G1BHe6deBPk5FVCQ@mail.gmail.com>
	(Kay Sievers's message of "Tue, 31 Jan 2012 12:58:46 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kay Sievers <kay.sievers@vrfy.org> writes:

> On Tue, Jan 31, 2012 at 12:17, Jiri Slaby <jslaby@suse.cz> wrote:
>> On 01/31/2012 12:13 PM, Kay Sievers wrote:
>
>>> This is a command sequence you type manually?
>>
>> Yea, and it is working with 3.3.0-rc1-next-20120124_64+. Not with
>> 3.3.0-rc1-next-20120131_64+.
>>
>>> You are sure that userspace is not working in the background,
>>> triggered by uevents, and comes into your way here?
>>
>> Note that krtek exists after the first command. But cannot be renamed
>> further.
>
> Yeah, I can confirm the problem here. I works fine with earlier
> kernels and fails with the latest -next:
>
> # uname -r
> 3.3.0-rc1-next-20120131+
> # modprobe dummy
> # ip link set dummy0 name foo0
> # ip link set foo0 name bar0
> RTNETLINK answers: No such file or directory

There is something weird going on when sysfs directories and symlinks
are renamed.  My guess is that I fat fingered something with one of my
last sysfs patches.  I will look more deeply once I have slept some
more.

The second network device renames fails because the first rename did not
work properly.  ls -l /sys/class/net/ /sys/virtual/net/ will let you see
what I mean.

Eric
