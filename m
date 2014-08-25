From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] crypto: tcrypt: new user interface with debugfs
Date: Mon, 25 Aug 2014 20:14:55 +0800
Message-ID: <20140825121455.GB27102@gondor.apana.org.au>
References: <1407643462-3355-1-git-send-email-luca.clementi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Luca Clementi <luca.clementi@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407643462-3355-1-git-send-email-luca.clementi@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 10, 2014 at 04:04:22AM +0000, Luca Clementi wrote:
> tcrypt is a kernel module which can be used to trigger speed tests on
> different parts of the crypto API. To trigger a test, users has to load the
> module using various module parameters, e.g.:
> 
>  # modprobe tcrypt mode=404 sec=5
> 
> All tcrypt tests are implemented in the _init function, their output is sent to
> the printk buffer, and once the test is over _init always returns a failure.
> 
> This patch modifies tcrypt in order to expose a debugfs user space interface
> which can be used to trigger tcrypt tests and to get their output. All tests
> output is redirected to an internal ring buffer.
> 
> The following files are available in the tcrypt debugfs directory:
> 
>  - command: this file can be use to control which test should be run simply
>             writing the test name to it. it also supports clearing the 'output'
>             buffer and listing all available tests
> 
>  - output:  holds a ring buffer with the output of the tests
> 
>  - seconds: this file can be used to control the number of seconds that a
>             tests should be run consecutively. If zero it uses CPU cycles
> 
> This patch is not for inclusion, but I'd like to know if my approach makes
> sense and if debugfs is the right place to expose a tcrypt interface.
> 
> Some functionalities available in the current version of the module are still
> missing in this version (in particular test_available and do_alg_test are not
> implemented yet). I also don't like the implementation of the 'fixed_tests' but
> as i said, this is just a prototype.
> 
> Signed-off-by: Luca Clementi <luca.clementi@gmail.com>

It's certainly an interesting idea.  However, one of the attractive
things about the current setup is the ease of use.  So I'd like to
hear from others who use tcrypt on what they feel about converting
over to something like debugfs.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
