From: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Subject: Re: O_DIRECT sockets? (was [RESEND] tuning linux for high network  performance?)
Date: Thu, 24 Oct 2002 12:14:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210241214.59812.roy@karlsbakk.net>
References: <200210231218.18733.roy@karlsbakk.net> <200210231726.21135.roy@karlsbakk.net> <3DB6CF9E.327E165F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com,
   Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3DB6CF9E.327E165F@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Hmm, I'm still not clear on why you cannot use sendfile()?
> I was not aware of any upper limit to the file size in order
> for sendfile() to be used?  From what little I know, this
> is exactly the kind of situation that sendfile was intended
> to benefit.

I can't use sendfile(). I'm working with files > 4GB, and from man 2 sendfile:

ssize_t sendfile(int out_fd, int in_fd, off_t *offset, size_t count);

int main() {
	ssize_t s1;
	off_t offset;
	size_t count;

	printf("sizeof ssize_t: %d\n", sizeof s1);
	printf("sizeof size_t: %d\n", sizeof count);
	printf("sizeof off_t: %d\n", sizeof offset);
	return 0;
}

running it

$ ./sendfile_test
sizeof ssize_t: 4
sizeof size_t: 4
sizeof off_t: 4
$ 

as far as I'm concerned, this will not allow me to address files past the 4GB 
limit (or was it 2?)

roy

-- 
Roy Sigurd Karlsbakk, Datavaktmester
ProntoTV AS - http://www.pronto.tv/
Tel: +47 9801 3356

Computers are like air conditioners.
They stop working when you open Windows.
